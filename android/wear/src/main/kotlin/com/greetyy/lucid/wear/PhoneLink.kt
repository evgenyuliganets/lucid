package com.greetyy.lucid.wear

import android.Manifest
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import com.greetyy.lucid.shared.AlarmSettings
import com.greetyy.lucid.shared.NightReport
import com.greetyy.lucid.shared.Sync
import com.greetyy.lucid.shared.WatchStatus

/** The watch side of the Wear Data Layer link to the phone app. */
object PhoneLink {
    fun publishStatus(context: Context) {
        val status = WatchStatus(
            notificationsAllowed = notificationsAllowed(context),
            fullScreenAllowed = fullScreenAllowed(context),
            heartRateAllowed = HeartRatePermission.allowed(context),
            armedWindowEndMillis = WatchPrefs(context).armedWindow?.end?.toEpochMilli(),
            tracking = NightService.trackingWindowEnd != null,
            appVersion = BuildConfig.VERSION_NAME,
        )
        put(context, Sync.WATCH_STATUS_PATH, status.encode())
    }

    fun sendNight(context: Context, report: NightReport) =
        put(context, Sync.nightPath(report.windowEndMillis), report.encode())

    fun sendDismissed(context: Context, windowEnd: Long) =
        put(context, Sync.WATCH_DISMISSED_PATH, windowEnd.toString())

    /** Reads the phone's alarm from the Data Layer, for a watch app installed after it was set. */
    fun pullSettings(context: Context, onDone: () -> Unit) {
        val uri = Uri.Builder().scheme("wear").path(Sync.SETTINGS_PATH).build()
        Wearable.getDataClient(context).getDataItems(uri).addOnCompleteListener { task ->
            val items = task.result
            val settings = items?.mapNotNull { item ->
                val map = DataMapItem.fromDataItem(item).dataMap
                val sentAt = map.getLong(Sync.KEY_SENT_AT)
                map.getString(Sync.KEY_VALUE)?.let(AlarmSettings::decode)?.let { sentAt to it }
            }?.maxByOrNull { it.first }?.second
            items?.release()
            if (settings != null && settings != WatchPrefs(context).settings) {
                WatchPrefs(context).settings = settings
                NightSchedule.arm(context)
            }
            onDone()
        }
    }

    fun notificationsAllowed(context: Context): Boolean =
        NotificationManagerCompat.from(context).areNotificationsEnabled() &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED

    fun fullScreenAllowed(context: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE ||
            context.getSystemService(NotificationManager::class.java).canUseFullScreenIntent()

    private fun put(context: Context, path: String, value: String) {
        val request = PutDataMapRequest.create(path).apply {
            dataMap.putString(Sync.KEY_VALUE, value)
            dataMap.putLong(Sync.KEY_SENT_AT, System.currentTimeMillis())
        }.asPutDataRequest().setUrgent()
        Wearable.getDataClient(context).putDataItem(request)
    }
}

/** Heart-rate permissions: Wear OS 6 split them out of BODY_SENSORS. */
object HeartRatePermission {
    val foreground: String =
        if (Build.VERSION.SDK_INT >= 36) "android.permission.health.READ_HEART_RATE" else Manifest.permission.BODY_SENSORS

    val background: String =
        if (Build.VERSION.SDK_INT >= 36) {
            "android.permission.health.READ_HEALTH_DATA_IN_BACKGROUND"
        } else {
            Manifest.permission.BODY_SENSORS_BACKGROUND
        }

    fun foregroundGranted(context: Context) = granted(context, foreground)

    /** Tracking starts from the background, so both are needed. */
    fun allowed(context: Context) = granted(context, foreground) && granted(context, background)

    private fun granted(context: Context, permission: String) =
        ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
}
