package com.greetyy.lucid.wear

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import java.time.Instant
import java.time.ZoneId
import java.time.ZonedDateTime

/**
 * Arms the watch for the next window: an exact alarm starts tracking
 * [TRACKING_LEAD_MILLIS] before the window, and an alarm-clock alarm rings at
 * the window end even if tracking never started.
 */
object NightSchedule {
    const val TRACKING_LEAD_MILLIS = 30 * 60_000L

    fun arm(context: Context) {
        val prefs = WatchPrefs(context)
        val alarmManager = context.getSystemService(AlarmManager::class.java)
        alarmManager.cancel(NightReceiver.trackIntent(context, null))
        alarmManager.cancel(NightReceiver.deadlineIntent(context, null))

        val now = ZonedDateTime.now()
        val handled = Instant.ofEpochMilli(prefs.handledWindowEnd).atZone(ZoneId.systemDefault())
        val window = prefs.settings?.nextWindow(maxOf(now, handled))
        prefs.armedWindow = window

        val tracking = NightService.trackingWindowEnd
        if (tracking != null && tracking != window?.end?.toEpochMilli()) NightService.stop(context)

        if (window != null) {
            val showApp = PendingIntent.getActivity(
                context,
                0,
                Intent(context, MainActivity::class.java),
                PendingIntent.FLAG_IMMUTABLE,
            )
            alarmManager.setAlarmClock(
                AlarmManager.AlarmClockInfo(window.end.toEpochMilli(), showApp),
                NightReceiver.deadlineIntent(context, window),
            )
            // Starting tracking goes through an exact alarm even when it is due now:
            // only an exact-alarm broadcast may start the health service from the background.
            val trackAt = maxOf(window.start.toEpochMilli() - TRACKING_LEAD_MILLIS, System.currentTimeMillis() + 1_000)
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                trackAt,
                NightReceiver.trackIntent(context, window),
            )
        }
        PhoneLink.publishStatus(context)
    }
}
