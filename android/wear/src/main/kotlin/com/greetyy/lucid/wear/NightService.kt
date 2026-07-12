package com.greetyy.lucid.wear

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.SystemClock
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.VibratorManager
import androidx.core.content.ContextCompat
import com.greetyy.lucid.shared.Epoch
import com.greetyy.lucid.shared.EpochAccumulator
import com.greetyy.lucid.shared.NightReport
import com.greetyy.lucid.shared.WakeDecision
import com.greetyy.lucid.shared.WakeDetector
import com.greetyy.lucid.shared.WakeReason
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

/**
 * Owns one night on the watch: tracking (accelerometer and optional heart rate
 * into [WakeDetector]) and then ringing (vibration and the alarm screen) until
 * the user dismisses or snoozes, or the phone reports a dismissal.
 */
class NightService : Service(), SensorEventListener {
    private val handler = Handler(Looper.getMainLooper())
    private val prefs by lazy { WatchPrefs(this) }
    private val sensors by lazy { getSystemService(SensorManager::class.java) }
    private val vibrator by lazy { getSystemService(VibratorManager::class.java).defaultVibrator }
    private var wakeLock: PowerManager.WakeLock? = null
    private var stopping = false

    private var windowStart = 0L
    private var windowEnd = 0L
    private var trackingStart = 0L
    private var detector: WakeDetector? = null
    private var accumulator: EpochAccumulator? = null
    private val epochs = mutableListOf<Epoch>()

    private val ringTimeout = Runnable { finishRing(dismissedAt = null, notifyPhone = true) }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        // A startForegroundService() call must reach startForeground() even when
        // the request turns out to be stale.
        if (action in FOREGROUND_ACTIONS && detector == null && ringState.value == null) {
            goForeground(trackingNotification())
        }
        when (action) {
            ACTION_TRACK -> startTracking(
                intent.getLongExtra(EXTRA_WINDOW_START, 0),
                intent.getLongExtra(EXTRA_WINDOW_END, 0),
            )
            ACTION_RING_DEADLINE -> ring(WakeReason.DEADLINE, intent.getLongExtra(EXTRA_WINDOW_END, 0))
            ACTION_TEST -> if (detector == null) ring(WakeReason.TEST, windowEnd = 0)
            ACTION_DISMISS -> finishRing(dismissedAt = System.currentTimeMillis(), notifyPhone = true)
            ACTION_PHONE_DISMISSED -> phoneDismissed(intent.getLongExtra(EXTRA_WINDOW_END, 0))
            ACTION_SNOOZE -> snooze()
            ACTION_STOP -> stopNight()
        }
        if (!stopping && detector == null && ringState.value == null) stopNight()
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        stopSensors()
        vibrator.cancel()
        handler.removeCallbacksAndMessages(null)
        releaseWakeLock()
        trackingWindowEnd = null
        ringState.value = null
        super.onDestroy()
    }

    private fun startTracking(start: Long, end: Long) {
        if (end <= System.currentTimeMillis() || end <= prefs.handledWindowEnd) return
        if (detector != null && windowEnd == end) return
        goForeground(trackingNotification())
        stopSensors()
        windowStart = start
        windowEnd = end
        trackingStart = System.currentTimeMillis()
        detector = WakeDetector(start, end)
        accumulator = EpochAccumulator(trackingStart)
        epochs.clear()
        holdWakeLock(end - trackingStart + RING_TIMEOUT_MILLIS)
        sensors.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)?.let {
            sensors.registerListener(this, it, ACCELEROMETER_PERIOD_US, BATCH_LATENCY_US, handler)
        }
        if (HeartRatePermission.allowed(this)) {
            sensors.getDefaultSensor(Sensor.TYPE_HEART_RATE)?.let {
                sensors.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL, BATCH_LATENCY_US, handler)
            }
        }
        trackingWindowEnd = end
        PhoneLink.publishStatus(this)
    }

    override fun onSensorChanged(event: SensorEvent) {
        val accumulator = accumulator ?: return
        // Sensor timestamps are elapsed-realtime nanos; batched events arrive late.
        val at = System.currentTimeMillis() - (SystemClock.elapsedRealtimeNanos() - event.timestamp) / 1_000_000
        val epoch = when (event.sensor.type) {
            Sensor.TYPE_ACCELEROMETER -> accumulator.addAcceleration(at, event.values[0], event.values[1], event.values[2])
            Sensor.TYPE_HEART_RATE -> accumulator.addHeartRate(at, event.values[0])
            else -> null
        } ?: return
        epochs += epoch
        val decision = detector?.onEpoch(epoch) ?: return
        if (decision is WakeDecision.Wake) ring(decision.reason, windowEnd)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    private fun ring(reason: WakeReason, windowEnd: Long) {
        if (ringState.value != null) return
        if (reason != WakeReason.TEST && (windowEnd == 0L || windowEnd <= prefs.handledWindowEnd)) return
        stopSensors()
        if (reason != WakeReason.TEST) {
            this.windowEnd = windowEnd
            // After a snooze the report from the first ring is kept.
            if (prefs.pendingReport?.windowEndMillis != windowEnd) {
                prefs.pendingReport = NightReport(
                    windowStartMillis = if (detector != null) windowStart else armedStart(windowEnd),
                    windowEndMillis = windowEnd,
                    trackingStartMillis = if (detector != null) trackingStart else windowEnd,
                    wokeAtMillis = System.currentTimeMillis(),
                    reason = reason,
                    dismissedAtMillis = null,
                    epochs = epochs.toList(),
                )
            }
        }
        detector = null
        accumulator = null
        ringState.value = reason
        holdWakeLock(RING_TIMEOUT_MILLIS + 60_000)
        goForeground(ringNotification(reason))
        vibrator.vibrate(
            VibrationEffect.createWaveform(VIBRATION_TIMINGS, VIBRATION_AMPLITUDES, VIBRATION_REPEAT_FROM),
            VibrationAttributes.createForUsage(VibrationAttributes.USAGE_ALARM),
        )
        handler.postDelayed(ringTimeout, RING_TIMEOUT_MILLIS)
        startActivity(
            Intent(this, RingActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        )
    }

    private fun armedStart(end: Long): Long =
        prefs.armedWindow?.takeIf { it.end.toEpochMilli() == end }?.start?.toEpochMilli() ?: end

    private fun finishRing(dismissedAt: Long?, notifyPhone: Boolean) {
        val reason = ringState.value ?: return
        vibrator.cancel()
        handler.removeCallbacks(ringTimeout)
        ringState.value = null
        if (reason != WakeReason.TEST) closeNight(dismissedAt, notifyPhone)
        stopNight()
    }

    private fun phoneDismissed(end: Long) {
        if (end != windowEnd) return
        if (ringState.value != null) {
            finishRing(dismissedAt = System.currentTimeMillis(), notifyPhone = false)
        } else {
            // The phone rang first (the watch was off the wrist or tracking failed).
            closeNight(dismissedAt = null, notifyPhone = false)
            stopNight()
        }
    }

    private fun closeNight(dismissedAt: Long?, notifyPhone: Boolean) {
        val report = prefs.pendingReport?.copy(dismissedAtMillis = dismissedAt)
            ?: NightReport(windowStart, windowEnd, trackingStart, null, null, dismissedAt, epochs.toList())
        prefs.pendingReport = null
        prefs.handledWindowEnd = maxOf(prefs.handledWindowEnd, windowEnd)
        PhoneLink.sendNight(this, report)
        if (notifyPhone && dismissedAt != null) PhoneLink.sendDismissed(this, windowEnd)
        NightSchedule.arm(this)
    }

    private fun snooze() {
        val reason = ringState.value ?: return
        vibrator.cancel()
        handler.removeCallbacks(ringTimeout)
        ringState.value = null
        if (reason != WakeReason.TEST) {
            getSystemService(AlarmManager::class.java).setAlarmClock(
                AlarmManager.AlarmClockInfo(System.currentTimeMillis() + SNOOZE_MILLIS, null),
                NightReceiver.snoozeOverIntent(this, windowEnd),
            )
        }
        stopNight()
    }

    private fun stopNight() {
        stopping = true
        stopSensors()
        detector = null
        accumulator = null
        trackingWindowEnd = null
        releaseWakeLock()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        PhoneLink.publishStatus(this)
    }

    private fun stopSensors() = sensors.unregisterListener(this)

    private fun holdWakeLock(timeoutMillis: Long) {
        releaseWakeLock()
        wakeLock = getSystemService(PowerManager::class.java)
            .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "lucid:night")
            .apply { acquire(timeoutMillis) }
    }

    private fun releaseWakeLock() {
        wakeLock?.takeIf { it.isHeld }?.release()
        wakeLock = null
    }

    private fun goForeground(notification: Notification) {
        stopping = false
        createChannels()
        startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH)
    }

    private fun trackingNotification(): Notification = Notification.Builder(this, CHANNEL_NIGHT)
        .setSmallIcon(R.mipmap.ic_launcher)
        .setContentTitle(getString(R.string.tracking_notification))
        .setOngoing(true)
        .setCategory(Notification.CATEGORY_STATUS)
        .setContentIntent(
            PendingIntent.getActivity(this, 0, Intent(this, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE),
        )
        .build()

    private fun ringNotification(reason: WakeReason): Notification {
        val ringScreen = PendingIntent.getActivity(
            this,
            1,
            Intent(this, RingActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = Notification.Builder(this, CHANNEL_ALARM)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(getString(R.string.ring_title))
            .setContentText(getString(ringMessage(reason)))
            .setCategory(Notification.CATEGORY_ALARM)
            .setOngoing(true)
            .setFullScreenIntent(ringScreen, true)
            .setContentIntent(ringScreen)
            .addAction(
                Notification.Action.Builder(null, getString(R.string.dismiss), NightReceiver.dismissIntent(this)).build(),
            )
        if (reason != WakeReason.TEST) {
            builder.addAction(
                Notification.Action.Builder(null, getString(R.string.snooze), NightReceiver.snoozeIntent(this)).build(),
            )
        }
        return builder.build()
    }

    private fun createChannels() {
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_NIGHT, getString(R.string.channel_night), NotificationManager.IMPORTANCE_LOW),
        )
        // Vibration comes from the service with alarm attributes, not from the channel.
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_ALARM, getString(R.string.channel_alarm), NotificationManager.IMPORTANCE_HIGH)
                .apply {
                    setSound(null, null)
                    enableVibration(false)
                },
        )
    }

    companion object {
        const val ACTION_DISMISS = "dismiss"
        const val ACTION_SNOOZE = "snooze"
        private const val ACTION_TRACK = "track"
        private const val ACTION_RING_DEADLINE = "ringDeadline"
        private const val ACTION_TEST = "test"
        private const val ACTION_PHONE_DISMISSED = "phoneDismissed"
        private const val ACTION_STOP = "stop"
        private val FOREGROUND_ACTIONS = setOf(ACTION_TRACK, ACTION_RING_DEADLINE, ACTION_TEST)
        private const val EXTRA_WINDOW_START = "windowStart"
        private const val EXTRA_WINDOW_END = "windowEnd"

        private const val CHANNEL_NIGHT = "night"
        private const val CHANNEL_ALARM = "alarm"
        private const val NOTIFICATION_ID = 1
        private const val ACCELEROMETER_PERIOD_US = 100_000
        private const val BATCH_LATENCY_US = 10_000_000
        private const val RING_TIMEOUT_MILLIS = 10 * 60_000L
        private const val SNOOZE_MILLIS = 5 * 60_000L

        // Gentle start: pulses grow stronger, then the last pulse repeats.
        private val VIBRATION_TIMINGS = longArrayOf(0, 300, 700, 300, 700, 500, 500, 800, 400)
        private val VIBRATION_AMPLITUDES = intArrayOf(0, 80, 0, 140, 0, 200, 0, 255, 0)
        private const val VIBRATION_REPEAT_FROM = 7

        private val ringState = MutableStateFlow<WakeReason?>(null)

        /** Why the watch is ringing right now, or null. */
        val ringing: StateFlow<WakeReason?> = ringState

        /** End of the window being tracked right now, or null. */
        @Volatile
        var trackingWindowEnd: Long? = null
            private set

        fun track(context: Context, windowStart: Long, windowEnd: Long) = ContextCompat.startForegroundService(
            context,
            Intent(context, NightService::class.java)
                .setAction(ACTION_TRACK)
                .putExtra(EXTRA_WINDOW_START, windowStart)
                .putExtra(EXTRA_WINDOW_END, windowEnd),
        )

        fun ringDeadline(context: Context, windowEnd: Long) = ContextCompat.startForegroundService(
            context,
            Intent(context, NightService::class.java)
                .setAction(ACTION_RING_DEADLINE)
                .putExtra(EXTRA_WINDOW_END, windowEnd),
        )

        /** From the main screen, which is in the foreground. */
        fun test(context: Context) = ContextCompat.startForegroundService(
            context,
            Intent(context, NightService::class.java).setAction(ACTION_TEST),
        )

        /** Dismiss or snooze; only meaningful while the service runs. */
        fun command(context: Context, action: String) {
            if (ringState.value == null) return
            context.startService(Intent(context, NightService::class.java).setAction(action))
        }

        fun stop(context: Context) {
            if (trackingWindowEnd == null && ringState.value == null) return
            context.startService(Intent(context, NightService::class.java).setAction(ACTION_STOP))
        }

        /** The phone's alarm was dismissed for [windowEnd]. */
        fun phoneDismissed(context: Context, windowEnd: Long) {
            val prefs = WatchPrefs(context)
            if (windowEnd <= prefs.handledWindowEnd) return
            if (trackingWindowEnd == windowEnd || ringState.value != null) {
                context.startService(
                    Intent(context, NightService::class.java)
                        .setAction(ACTION_PHONE_DISMISSED)
                        .putExtra(EXTRA_WINDOW_END, windowEnd),
                )
            } else {
                prefs.pendingReport = null
                prefs.handledWindowEnd = windowEnd
                NightSchedule.arm(context)
            }
        }
    }
}
