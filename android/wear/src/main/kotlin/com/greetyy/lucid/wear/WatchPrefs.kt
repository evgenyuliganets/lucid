package com.greetyy.lucid.wear

import android.content.Context
import androidx.core.content.edit
import com.greetyy.lucid.shared.AlarmSettings
import com.greetyy.lucid.shared.NightReport
import com.greetyy.lucid.shared.WakeWindow
import java.time.Instant

/** The watch's persisted state: the synced alarm and where tonight stands. */
class WatchPrefs(context: Context) {
    private val prefs = context.applicationContext.getSharedPreferences("lucid", Context.MODE_PRIVATE)

    var settings: AlarmSettings?
        get() = prefs.getString(KEY_SETTINGS, null)?.let(AlarmSettings::decode)
        set(value) = prefs.edit { putString(KEY_SETTINGS, value?.encode()) }

    /** The window that was armed last, for the main screen and the phone. */
    var armedWindow: WakeWindow?
        get() {
            val start = prefs.getLong(KEY_ARMED_START, 0)
            val end = prefs.getLong(KEY_ARMED_END, 0)
            return if (end == 0L) null else WakeWindow(Instant.ofEpochMilli(start), Instant.ofEpochMilli(end))
        }
        set(value) = prefs.edit {
            putLong(KEY_ARMED_START, value?.start?.toEpochMilli() ?: 0)
            putLong(KEY_ARMED_END, value?.end?.toEpochMilli() ?: 0)
        }

    /** End of the last window that rang and was finished; the next arm skips it. */
    var handledWindowEnd: Long
        get() = prefs.getLong(KEY_HANDLED_END, 0)
        set(value) = prefs.edit { putLong(KEY_HANDLED_END, value) }

    /** Tonight's report from the moment the alarm rang until it is dismissed (survives snooze). */
    var pendingReport: NightReport?
        get() = prefs.getString(KEY_PENDING_REPORT, null)?.let(NightReport::decode)
        set(value) = prefs.edit { putString(KEY_PENDING_REPORT, value?.encode()) }

    private companion object {
        const val KEY_SETTINGS = "settings"
        const val KEY_ARMED_START = "armedStart"
        const val KEY_ARMED_END = "armedEnd"
        const val KEY_HANDLED_END = "handledEnd"
        const val KEY_PENDING_REPORT = "pendingReport"
    }
}
