package com.greetyy.lucid

import android.content.Context
import androidx.core.content.edit
import com.greetyy.lucid.shared.AlarmSettings
import com.greetyy.lucid.shared.NightReport
import com.greetyy.lucid.shared.WatchStatus

/**
 * The phone's persisted state. The alarm lives here, not in Dart, so the boot
 * receiver and the watch listener can re-arm without starting Flutter.
 */
class PhoneStore(context: Context) {
    // Device-protected storage: the alarm must re-arm after a reboot before the first unlock.
    private val prefs = context.applicationContext.createDeviceProtectedStorageContext()
        .getSharedPreferences("lucid", Context.MODE_PRIVATE)

    var settings: AlarmSettings
        get() = prefs.getString(KEY_SETTINGS, null)?.let(AlarmSettings::decode) ?: AlarmSettings.DEFAULT
        set(value) = prefs.edit { putString(KEY_SETTINGS, value.encode()) }

    /** End of the last window that rang and was finished on either device. */
    var handledWindowEnd: Long
        get() = prefs.getLong(KEY_HANDLED_END, 0)
        set(value) = prefs.edit { putLong(KEY_HANDLED_END, value) }

    /** Window end the phone is ringing for right now (0 = test ring, -1 = none). */
    var ringingWindowEnd: Long
        get() = prefs.getLong(KEY_RINGING_END, -1)
        set(value) = prefs.edit { putLong(KEY_RINGING_END, value) }

    val watchStatus: WatchStatus?
        get() = prefs.getString(KEY_WATCH_STATUS, null)?.let(WatchStatus::decode)

    val watchStatusAt: Long
        get() = prefs.getLong(KEY_WATCH_STATUS_AT, 0)

    fun saveWatchStatus(status: WatchStatus) = prefs.edit {
        putString(KEY_WATCH_STATUS, status.encode())
        putLong(KEY_WATCH_STATUS_AT, System.currentTimeMillis())
    }

    /** Watch reports, newest first, at most [MAX_NIGHTS]. */
    val nights: List<NightReport>
        get() = prefs.getStringSet(KEY_NIGHTS, emptySet()).orEmpty()
            .mapNotNull(NightReport::decode)
            .sortedByDescending { it.windowEndMillis }

    fun saveNight(report: NightReport) {
        val kept = (nights.filter { it.windowEndMillis != report.windowEndMillis } + report)
            .sortedByDescending { it.windowEndMillis }
            .take(MAX_NIGHTS)
        prefs.edit { putStringSet(KEY_NIGHTS, kept.map { it.encode() }.toSet()) }
    }

    private companion object {
        const val KEY_SETTINGS = "settings"
        const val KEY_HANDLED_END = "handledEnd"
        const val KEY_RINGING_END = "ringingEnd"
        const val KEY_WATCH_STATUS = "watchStatus"
        const val KEY_WATCH_STATUS_AT = "watchStatusAt"
        const val KEY_NIGHTS = "nights"
        const val MAX_NIGHTS = 30
    }
}
