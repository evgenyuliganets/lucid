package com.greetyy.lucid.shared

import java.time.DayOfWeek
import java.time.Instant
import java.time.ZonedDateTime

/**
 * The one alarm Lucid has. The phone owns it and syncs it to the watch.
 *
 * [wakeByMinute] is the latest wake time (minutes after midnight); the smart
 * window is the [windowMinutes] before it. [days] are the days of the wake
 * time; empty means a one-time alarm that the phone switches off after it rang.
 */
data class AlarmSettings(
    val enabled: Boolean,
    val wakeByMinute: Int,
    val windowMinutes: Int,
    val days: Set<DayOfWeek>,
) {
    init {
        require(wakeByMinute in 0 until MINUTES_PER_DAY) { "wakeByMinute out of range" }
        require(windowMinutes in 0..MAX_WINDOW_MINUTES) { "windowMinutes out of range" }
    }

    val isOneTime: Boolean get() = days.isEmpty()

    /** The next window whose end is still ahead of [now], or null when off. */
    fun nextWindow(now: ZonedDateTime): WakeWindow? {
        if (!enabled) return null
        val today = now.toLocalDate()
        for (offset in 0L..7L) {
            val date = today.plusDays(offset)
            if (days.isNotEmpty() && date.dayOfWeek !in days) continue
            val end = date.atStartOfDay(now.zone).plusMinutes(wakeByMinute.toLong())
            if (end.isAfter(now)) {
                return WakeWindow(
                    start = end.minusMinutes(windowMinutes.toLong()).toInstant(),
                    end = end.toInstant(),
                )
            }
        }
        return null
    }

    fun encode(): String {
        val dayBits = days.sumOf { 1 shl (it.value - 1) }
        return listOf(if (enabled) 1 else 0, wakeByMinute, windowMinutes, dayBits).joinToString(";")
    }

    companion object {
        const val MINUTES_PER_DAY = 24 * 60
        const val MAX_WINDOW_MINUTES = 90

        val DEFAULT = AlarmSettings(
            enabled = false,
            wakeByMinute = 7 * 60,
            windowMinutes = 30,
            days = setOf(
                DayOfWeek.MONDAY,
                DayOfWeek.TUESDAY,
                DayOfWeek.WEDNESDAY,
                DayOfWeek.THURSDAY,
                DayOfWeek.FRIDAY,
            ),
        )

        /** Null when [text] is not a value written by [encode]. */
        fun decode(text: String): AlarmSettings? {
            val parts = text.split(";")
            if (parts.size != 4) return null
            val enabled = parts[0].toIntOrNull() ?: return null
            val wakeBy = parts[1].toIntOrNull() ?: return null
            val window = parts[2].toIntOrNull() ?: return null
            val dayBits = parts[3].toIntOrNull() ?: return null
            if (enabled !in 0..1 || wakeBy !in 0 until MINUTES_PER_DAY) return null
            if (window !in 0..MAX_WINDOW_MINUTES || dayBits !in 0..0x7F) return null
            val days = DayOfWeek.entries.filter { dayBits and (1 shl (it.value - 1)) != 0 }.toSet()
            return AlarmSettings(enabled == 1, wakeBy, window, days)
        }
    }
}

/** One night's smart window; the alarm rings at [end] at the latest. */
data class WakeWindow(val start: Instant, val end: Instant)
