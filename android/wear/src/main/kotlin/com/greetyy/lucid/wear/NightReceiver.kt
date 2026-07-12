package com.greetyy.lucid.wear

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.greetyy.lucid.shared.WakeWindow

/** Exact-alarm and notification-action entry points into [NightService]. */
class NightReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val start = intent.getLongExtra(EXTRA_WINDOW_START, 0)
        val end = intent.getLongExtra(EXTRA_WINDOW_END, 0)
        when (intent.action) {
            ACTION_TRACK -> NightService.track(context, start, end)
            ACTION_DEADLINE, ACTION_SNOOZE_OVER -> NightService.ringDeadline(context, end)
            ACTION_DISMISS -> NightService.command(context, NightService.ACTION_DISMISS)
            ACTION_SNOOZE -> NightService.command(context, NightService.ACTION_SNOOZE)
        }
    }

    companion object {
        private const val ACTION_TRACK = "com.greetyy.lucid.TRACK"
        private const val ACTION_DEADLINE = "com.greetyy.lucid.DEADLINE"
        private const val ACTION_SNOOZE_OVER = "com.greetyy.lucid.SNOOZE_OVER"
        private const val ACTION_DISMISS = "com.greetyy.lucid.DISMISS"
        private const val ACTION_SNOOZE = "com.greetyy.lucid.SNOOZE"
        private const val EXTRA_WINDOW_START = "windowStart"
        private const val EXTRA_WINDOW_END = "windowEnd"

        fun trackIntent(context: Context, window: WakeWindow?) = alarmIntent(context, ACTION_TRACK, 1, window)

        fun deadlineIntent(context: Context, window: WakeWindow?) = alarmIntent(context, ACTION_DEADLINE, 2, window)

        fun snoozeOverIntent(context: Context, windowEnd: Long) = PendingIntent.getBroadcast(
            context,
            3,
            Intent(context, NightReceiver::class.java)
                .setAction(ACTION_SNOOZE_OVER)
                .putExtra(EXTRA_WINDOW_END, windowEnd),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        fun dismissIntent(context: Context) = actionIntent(context, ACTION_DISMISS, 4)

        fun snoozeIntent(context: Context) = actionIntent(context, ACTION_SNOOZE, 5)

        private fun alarmIntent(context: Context, action: String, requestCode: Int, window: WakeWindow?): PendingIntent {
            val intent = Intent(context, NightReceiver::class.java).setAction(action)
            window?.let {
                intent.putExtra(EXTRA_WINDOW_START, it.start.toEpochMilli())
                intent.putExtra(EXTRA_WINDOW_END, it.end.toEpochMilli())
            }
            return PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
        }

        private fun actionIntent(context: Context, action: String, requestCode: Int) = PendingIntent.getBroadcast(
            context,
            requestCode,
            Intent(context, NightReceiver::class.java).setAction(action),
            PendingIntent.FLAG_IMMUTABLE,
        )
    }
}

/** Re-arms after a reboot, an app update or a clock change. */
class RearmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        NightSchedule.arm(context)
    }
}
