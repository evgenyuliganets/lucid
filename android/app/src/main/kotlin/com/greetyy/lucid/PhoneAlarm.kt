package com.greetyy.lucid

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import java.time.Instant
import java.time.ZoneId
import java.time.ZonedDateTime

/**
 * The phone's fallback alarm: it rings at the window end unless the watch
 * already woke the user and the alarm was dismissed there. Dismissing on
 * either device stops both.
 */
object PhoneAlarm {
    private const val CHANNEL_ALARM = "alarm_v1"
    private const val NOTIFICATION_ID = 1
    private const val RING_TIMEOUT_MILLIS = 10 * 60_000L
    private const val SNOOZE_MILLIS = 5 * 60_000L
    private val VIBRATION = longArrayOf(0, 600, 400, 600, 400, 900, 600)

    /** Schedules the next window end, or cancels when the alarm is off. */
    fun arm(context: Context) {
        val store = PhoneStore(context)
        val alarmManager = context.getSystemService(AlarmManager::class.java)
        alarmManager.cancel(AlarmReceiver.ringIntent(context, 0))
        val handled = Instant.ofEpochMilli(store.handledWindowEnd).atZone(ZoneId.systemDefault())
        val window = store.settings.nextWindow(maxOf(ZonedDateTime.now(), handled)) ?: return
        val end = window.end.toEpochMilli()
        alarmManager.setAlarmClock(
            AlarmManager.AlarmClockInfo(end, openApp(context)),
            AlarmReceiver.ringIntent(context, end),
        )
    }

    /** Settings changed in the app: store, re-arm and send to the watch. */
    fun saveSettings(context: Context, settings: com.greetyy.lucid.shared.AlarmSettings) {
        PhoneStore(context).settings = settings
        arm(context)
        WatchLink.pushSettings(context, settings)
    }

    /** [windowEnd] 0 is a test ring that touches no state. */
    fun ring(context: Context, windowEnd: Long) {
        val store = PhoneStore(context)
        if (windowEnd != 0L && windowEnd <= store.handledWindowEnd) return
        store.ringingWindowEnd = windowEnd
        val manager = context.getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_ALARM, context.getString(R.string.channel_alarm), NotificationManager.IMPORTANCE_HIGH)
                .apply {
                    setSound(
                        RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM),
                        AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_ALARM).build(),
                    )
                    vibrationPattern = VIBRATION
                    enableVibration(true)
                },
        )
        val ringScreen = PendingIntent.getActivity(
            context,
            1,
            Intent(context, RingActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_IMMUTABLE,
        )
        val text = if (windowEnd == 0L) R.string.ring_test else R.string.ring_text
        val notification = Notification.Builder(context, CHANNEL_ALARM)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(context.getString(R.string.ring_title))
            .setContentText(context.getString(text))
            .setCategory(Notification.CATEGORY_ALARM)
            .setOngoing(true)
            .setFullScreenIntent(ringScreen, true)
            .setContentIntent(ringScreen)
            .setTimeoutAfter(RING_TIMEOUT_MILLIS)
            .addAction(Notification.Action.Builder(null, context.getString(R.string.dismiss), AlarmReceiver.dismissIntent(context)).build())
            .addAction(Notification.Action.Builder(null, context.getString(R.string.snooze), AlarmReceiver.snoozeIntent(context)).build())
            .build()
        // Insistent: the alarm sound repeats until the notification goes away.
        notification.flags = notification.flags or Notification.FLAG_INSISTENT
        manager.notify(NOTIFICATION_ID, notification)
    }

    fun dismiss(context: Context) {
        val store = PhoneStore(context)
        val windowEnd = store.ringingWindowEnd
        stopRinging(context)
        if (windowEnd > 0) {
            finishWindow(context, windowEnd)
            WatchLink.sendPhoneDismissed(context, windowEnd)
        }
        LucidEvents.changed()
    }

    fun snooze(context: Context) {
        val windowEnd = PhoneStore(context).ringingWindowEnd
        stopRinging(context)
        if (windowEnd < 0) return
        context.getSystemService(AlarmManager::class.java).setAlarmClock(
            AlarmManager.AlarmClockInfo(System.currentTimeMillis() + SNOOZE_MILLIS, openApp(context)),
            AlarmReceiver.snoozeOverIntent(context, windowEnd),
        )
    }

    /** The watch's alarm was dismissed for [windowEnd]. */
    fun watchDismissed(context: Context, windowEnd: Long) {
        val store = PhoneStore(context)
        if (windowEnd <= store.handledWindowEnd) return
        if (store.ringingWindowEnd == windowEnd) stopRinging(context)
        finishWindow(context, windowEnd)
        LucidEvents.changed()
    }

    private fun finishWindow(context: Context, windowEnd: Long) {
        val store = PhoneStore(context)
        store.handledWindowEnd = maxOf(store.handledWindowEnd, windowEnd)
        val settings = store.settings
        if (settings.isOneTime && settings.enabled) {
            saveSettings(context, settings.copy(enabled = false))
        } else {
            arm(context)
        }
    }

    private fun stopRinging(context: Context) {
        context.getSystemService(NotificationManager::class.java).cancel(NOTIFICATION_ID)
        context.getSystemService(AlarmManager::class.java).cancel(AlarmReceiver.snoozeOverIntent(context, 0))
        PhoneStore(context).ringingWindowEnd = -1
        RingActivity.closeAll()
    }

    private fun openApp(context: Context) = PendingIntent.getActivity(
        context,
        0,
        Intent(context, MainActivity::class.java),
        PendingIntent.FLAG_IMMUTABLE,
    )
}

/** Alarm-clock and notification-action entry points into [PhoneAlarm]. */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_RING -> PhoneAlarm.ring(context, intent.getLongExtra(EXTRA_WINDOW_END, -1))
            ACTION_DISMISS -> PhoneAlarm.dismiss(context)
            ACTION_SNOOZE -> PhoneAlarm.snooze(context)
        }
    }

    companion object {
        private const val ACTION_RING = "com.greetyy.lucid.RING"
        private const val ACTION_DISMISS = "com.greetyy.lucid.DISMISS"
        private const val ACTION_SNOOZE = "com.greetyy.lucid.SNOOZE"
        private const val EXTRA_WINDOW_END = "windowEnd"

        fun ringIntent(context: Context, windowEnd: Long) = PendingIntent.getBroadcast(
            context,
            1,
            Intent(context, AlarmReceiver::class.java).setAction(ACTION_RING).putExtra(EXTRA_WINDOW_END, windowEnd),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        fun snoozeOverIntent(context: Context, windowEnd: Long) = PendingIntent.getBroadcast(
            context,
            2,
            Intent(context, AlarmReceiver::class.java).setAction(ACTION_RING).putExtra(EXTRA_WINDOW_END, windowEnd),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        fun dismissIntent(context: Context) = PendingIntent.getBroadcast(
            context,
            3,
            Intent(context, AlarmReceiver::class.java).setAction(ACTION_DISMISS),
            PendingIntent.FLAG_IMMUTABLE,
        )

        fun snoozeIntent(context: Context) = PendingIntent.getBroadcast(
            context,
            4,
            Intent(context, AlarmReceiver::class.java).setAction(ACTION_SNOOZE),
            PendingIntent.FLAG_IMMUTABLE,
        )
    }
}

/** Re-arms after a reboot, an app update or a clock change, and resends the alarm to the watch. */
class RearmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        PhoneAlarm.arm(context)
        WatchLink.pushSettings(context, PhoneStore(context).settings)
    }
}
