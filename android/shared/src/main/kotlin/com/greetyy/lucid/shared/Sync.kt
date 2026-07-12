package com.greetyy.lucid.shared

/**
 * Wear Data Layer paths and keys shared by the phone and the watch. Each data
 * item carries one string value under [KEY_VALUE] written by an encode()
 * function in this module, plus [KEY_SENT_AT] so a re-sent equal value still
 * counts as a change.
 */
object Sync {
    const val WATCH_CAPABILITY = "lucid_watch_app"

    /** Phone -> watch: [AlarmSettings.encode]. */
    const val SETTINGS_PATH = "/lucid/settings"

    /** Watch -> phone: [WatchStatus.encode]. */
    const val WATCH_STATUS_PATH = "/lucid/watch/status"

    /** Watch -> phone: [NightReport.encode]; one item per night, keyed by window end. */
    const val NIGHT_PATH_PREFIX = "/lucid/night/"

    /** Watch -> phone and phone -> watch: the window end (epoch millis) that was dismissed. */
    const val WATCH_DISMISSED_PATH = "/lucid/watch/dismissed"
    const val PHONE_DISMISSED_PATH = "/lucid/phone/dismissed"

    const val KEY_VALUE = "value"
    const val KEY_SENT_AT = "sentAt"

    fun nightPath(windowEndMillis: Long) = "$NIGHT_PATH_PREFIX$windowEndMillis"
}

/** What the phone shows about the watch app. */
data class WatchStatus(
    val notificationsAllowed: Boolean,
    val fullScreenAllowed: Boolean,
    val heartRateAllowed: Boolean,
    val armedWindowEndMillis: Long?,
    val tracking: Boolean,
    val appVersion: String,
) {
    fun encode(): String = listOf(
        flag(notificationsAllowed),
        flag(fullScreenAllowed),
        flag(heartRateAllowed),
        armedWindowEndMillis?.toString().orEmpty(),
        flag(tracking),
        appVersion.replace("|", ""),
    ).joinToString("|")

    companion object {
        fun decode(text: String): WatchStatus? {
            val parts = text.split("|")
            if (parts.size != 6) return null
            return WatchStatus(
                notificationsAllowed = parts[0] == "1",
                fullScreenAllowed = parts[1] == "1",
                heartRateAllowed = parts[2] == "1",
                armedWindowEndMillis = parts[3].takeIf { it.isNotEmpty() }?.toLongOrNull(),
                tracking = parts[4] == "1",
                appVersion = parts[5],
            )
        }
    }
}

/** One night as the watch saw it, for the phone's morning view. */
data class NightReport(
    val windowStartMillis: Long,
    val windowEndMillis: Long,
    val trackingStartMillis: Long,
    val wokeAtMillis: Long?,
    val reason: WakeReason?,
    val dismissedAtMillis: Long?,
    val epochs: List<Epoch>,
) {
    fun encode(): String {
        val epochText = epochs.joinToString(",") { epoch ->
            val heartRate = epoch.heartRate?.let { "%.1f".format(java.util.Locale.ROOT, it) }.orEmpty()
            "${epoch.endsAtMillis}:${"%.4f".format(java.util.Locale.ROOT, epoch.movement)}:$heartRate"
        }
        return listOf(
            "1",
            windowStartMillis,
            windowEndMillis,
            trackingStartMillis,
            wokeAtMillis ?: "",
            reason?.name.orEmpty(),
            dismissedAtMillis ?: "",
            epochText,
        ).joinToString("|")
    }

    companion object {
        fun decode(text: String): NightReport? {
            val parts = text.split("|")
            if (parts.size != 8 || parts[0] != "1") return null
            val epochs = if (parts[7].isEmpty()) {
                emptyList()
            } else {
                parts[7].split(",").map { item ->
                    val fields = item.split(":")
                    if (fields.size != 3) return null
                    Epoch(
                        endsAtMillis = fields[0].toLongOrNull() ?: return null,
                        movement = fields[1].toDoubleOrNull() ?: return null,
                        heartRate = fields[2].takeIf { it.isNotEmpty() }?.toDoubleOrNull(),
                    )
                }
            }
            return NightReport(
                windowStartMillis = parts[1].toLongOrNull() ?: return null,
                windowEndMillis = parts[2].toLongOrNull() ?: return null,
                trackingStartMillis = parts[3].toLongOrNull() ?: return null,
                wokeAtMillis = parts[4].toLongOrNull(),
                reason = WakeReason.entries.firstOrNull { it.name == parts[5] },
                dismissedAtMillis = parts[6].toLongOrNull(),
                epochs = epochs,
            )
        }
    }
}

private fun flag(value: Boolean) = if (value) "1" else "0"
