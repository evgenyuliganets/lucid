package com.greetyy.lucid

import android.Manifest
import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.greetyy.lucid.shared.AlarmSettings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import java.time.DayOfWeek
import java.time.ZonedDateTime

/**
 * `lucid/alarm`: the alarm, the phone's alarm permissions and the watch.
 * Dart validates everything this returns.
 */
class AlarmChannel(
    messenger: BinaryMessenger,
    private val activity: Activity,
    private val scope: CoroutineScope,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, NAME).also { it.setMethodCallHandler(this) }
    private var pendingPermission: MethodChannel.Result? = null

    init {
        LucidEvents.listener = { channel.invokeMethod("changed", null) }
    }

    fun dispose() {
        LucidEvents.listener = null
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getState" -> replyState(result)
            "saveSettings" -> {
                val settings = parseSettings(call.arguments)
                if (settings == null) {
                    result.error("invalidSettings", "Settings are invalid", null)
                } else {
                    PhoneAlarm.saveSettings(activity, settings)
                    replyState(result)
                }
            }
            "requestNotifications" -> requestNotifications(result)
            "openNotificationSettings" -> open(result, Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            "openExactAlarmSettings" -> open(result, Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
            "openFullScreenSettings" -> open(result, Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT)
            "requestBatteryUnrestricted" -> open(result, Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            "openWearApp" -> openWearApp(result)
            "testAlarm" -> {
                PhoneAlarm.ring(activity, windowEnd = 0)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** From MainActivity.onRequestPermissionsResult. */
    fun onPermissionResult() {
        pendingPermission?.let { replyState(it) }
        pendingPermission = null
    }

    private fun replyState(result: MethodChannel.Result) {
        scope.launch {
            val info = WatchLink.watchInfo(activity)
            result.success(stateMap(info))
        }
    }

    private fun stateMap(info: WatchLink.WatchInfo): Map<String, Any?> {
        val store = PhoneStore(activity)
        val settings = store.settings
        val now = ZonedDateTime.now()
        val handled = java.time.Instant.ofEpochMilli(store.handledWindowEnd).atZone(now.zone)
        val window = settings.nextWindow(maxOf(now, handled))
        val status = store.watchStatus
        return mapOf(
            "settings" to mapOf(
                "enabled" to settings.enabled,
                "wakeByMinute" to settings.wakeByMinute,
                "windowMinutes" to settings.windowMinutes,
                "days" to settings.days.map { it.value }.sorted(),
            ),
            "nextWindow" to window?.let { mapOf("start" to it.start.toEpochMilli(), "end" to it.end.toEpochMilli()) },
            "phone" to mapOf(
                "notifications" to notificationsAllowed(),
                "exactAlarms" to activity.getSystemService(AlarmManager::class.java).canScheduleExactAlarms(),
                "fullScreen" to fullScreenAllowed(),
                "batteryUnrestricted" to activity.getSystemService(PowerManager::class.java)
                    .isIgnoringBatteryOptimizations(activity.packageName),
            ),
            "watch" to mapOf(
                "connected" to info.connected,
                "installed" to info.installed,
                "name" to info.name,
                "statusAt" to store.watchStatusAt.takeIf { it > 0 },
                "status" to status?.let {
                    mapOf(
                        "notifications" to it.notificationsAllowed,
                        "fullScreen" to it.fullScreenAllowed,
                        "heartRate" to it.heartRateAllowed,
                        "armedWindowEnd" to it.armedWindowEndMillis,
                        "tracking" to it.tracking,
                        "appVersion" to it.appVersion,
                    )
                },
            ),
        )
    }

    private fun notificationsAllowed(): Boolean {
        val granted = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            ContextCompat.checkSelfPermission(activity, Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        return granted && NotificationManagerCompat.from(activity).areNotificationsEnabled()
    }

    private fun fullScreenAllowed(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE ||
            activity.getSystemService(NotificationManager::class.java).canUseFullScreenIntent()

    private fun requestNotifications(result: MethodChannel.Result) {
        val granted = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            ContextCompat.checkSelfPermission(activity, Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        if (granted) {
            // Granted but switched off in the system settings.
            open(result, Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            return
        }
        pendingPermission?.let { replyState(it) }
        pendingPermission = result
        activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), PERMISSION_REQUEST)
    }

    private fun open(result: MethodChannel.Result, action: String) {
        val intent = Intent(action).apply {
            if (action == Settings.ACTION_APP_NOTIFICATION_SETTINGS) {
                putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
            } else {
                data = Uri.parse("package:${activity.packageName}")
            }
        }
        val opened = runCatching { activity.startActivity(intent) }.isSuccess ||
            runCatching {
                activity.startActivity(
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${activity.packageName}")),
                )
            }.isSuccess
        result.success(opened)
    }

    /** The Galaxy Wearable app, where the user installs apps on the watch. */
    private fun openWearApp(result: MethodChannel.Result) {
        val launch = WEAR_COMPANION_PACKAGES.firstNotNullOfOrNull {
            activity.packageManager.getLaunchIntentForPackage(it)
        }
        result.success(launch != null && runCatching { activity.startActivity(launch) }.isSuccess)
    }

    private fun parseSettings(arguments: Any?): AlarmSettings? {
        val map = arguments as? Map<*, *> ?: return null
        if (map.keys != setOf("enabled", "wakeByMinute", "windowMinutes", "days")) return null
        val enabled = map["enabled"] as? Boolean ?: return null
        val wakeBy = (map["wakeByMinute"] as? Number)?.toInt() ?: return null
        val window = (map["windowMinutes"] as? Number)?.toInt() ?: return null
        val dayValues = (map["days"] as? List<*>)?.map { (it as? Number)?.toInt() ?: return null } ?: return null
        if (wakeBy !in 0 until AlarmSettings.MINUTES_PER_DAY) return null
        if (window !in 0..AlarmSettings.MAX_WINDOW_MINUTES) return null
        if (dayValues.any { it !in 1..7 }) return null
        return AlarmSettings(enabled, wakeBy, window, dayValues.map(DayOfWeek::of).toSet())
    }

    companion object {
        const val NAME = "lucid/alarm"
        const val PERMISSION_REQUEST = 41
        private val WEAR_COMPANION_PACKAGES = listOf(
            "com.samsung.android.app.watchmanager",
            "com.google.android.wearable.app",
            "com.google.android.apps.wear.companion",
        )
    }
}

/** Native-side changes (watch status, a dismissal) that the Flutter UI should reload. */
object LucidEvents {
    private val main = Handler(Looper.getMainLooper())

    @Volatile
    var listener: (() -> Unit)? = null

    fun changed() {
        main.post { listener?.invoke() }
    }
}
