package com.greetyy.lucid.shared

import java.time.DayOfWeek
import java.time.ZoneId
import java.time.ZonedDateTime
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class AlarmSettingsTest {
    private val zone = ZoneId.of("Europe/Kyiv")

    // 2026-11-16 is a Monday.
    private fun at(day: Int, hour: Int, minute: Int) = ZonedDateTime.of(2026, 11, day, hour, minute, 0, 0, zone)

    private val weekdays = AlarmSettings(true, 7 * 60, 30, setOf(DayOfWeek.MONDAY, DayOfWeek.TUESDAY))

    @Test
    fun `next window is today when the wake time is still ahead`() {
        val window = weekdays.nextWindow(at(16, 22, 0).minusDays(1).withHour(5))
        assertEquals(at(16, 6, 30).toInstant(), window?.start)
        assertEquals(at(16, 7, 0).toInstant(), window?.end)
    }

    @Test
    fun `inside the window the current window is returned`() {
        val window = weekdays.nextWindow(at(16, 6, 45))
        assertEquals(at(16, 7, 0).toInstant(), window?.end)
    }

    @Test
    fun `after the wake time the next selected day is used`() {
        assertEquals(at(17, 7, 0).toInstant(), weekdays.nextWindow(at(16, 7, 0))?.end)
        assertEquals(at(23, 7, 0).toInstant(), weekdays.nextWindow(at(17, 8, 0))?.end)
    }

    @Test
    fun `one-time alarm takes the next occurrence of the time`() {
        val once = weekdays.copy(days = emptySet())
        assertEquals(at(17, 7, 0).toInstant(), once.nextWindow(at(16, 23, 0))?.end)
    }

    @Test
    fun `disabled alarm has no window`() {
        assertNull(weekdays.copy(enabled = false).nextWindow(at(16, 5, 0)))
    }

    @Test
    fun `window across midnight starts the evening before`() {
        val early = AlarmSettings(true, 10, 30, emptySet())
        val window = early.nextWindow(at(16, 20, 0))
        assertEquals(at(16, 23, 40).toInstant(), window?.start)
        assertEquals(at(17, 0, 10).toInstant(), window?.end)
    }

    @Test
    fun `daylight-saving days keep the local wake time`() {
        val daily = weekdays.copy(days = emptySet())
        val spring = daily.nextWindow(ZonedDateTime.of(2027, 3, 28, 1, 0, 0, 0, zone))
        assertEquals(ZonedDateTime.of(2027, 3, 28, 7, 0, 0, 0, zone).toInstant(), spring?.end)
        val autumn = daily.nextWindow(ZonedDateTime.of(2027, 10, 31, 1, 0, 0, 0, zone))
        assertEquals(ZonedDateTime.of(2027, 10, 31, 7, 0, 0, 0, zone).toInstant(), autumn?.end)
    }

    @Test
    fun `a handled window is skipped`() {
        val handled = at(16, 7, 0).toInstant().toEpochMilli()
        assertEquals(at(17, 7, 0).toInstant(), weekdays.nextWindow(at(16, 6, 50), handled)?.end)
    }

    @Test
    fun `encode and decode round trip`() {
        assertEquals(weekdays, AlarmSettings.decode(weekdays.encode()))
        assertEquals(AlarmSettings.DEFAULT, AlarmSettings.decode(AlarmSettings.DEFAULT.encode()))
    }

    @Test
    fun `decode rejects foreign text`() {
        assertNull(AlarmSettings.decode(""))
        assertNull(AlarmSettings.decode("1;2000;30;3"))
        assertNull(AlarmSettings.decode("1;420;30;999"))
        assertNull(AlarmSettings.decode("x;420;30;3"))
    }
}
