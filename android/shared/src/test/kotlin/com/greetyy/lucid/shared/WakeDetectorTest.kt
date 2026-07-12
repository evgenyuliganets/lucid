package com.greetyy.lucid.shared

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class WakeDetectorTest {
    private val minute = 60_000L
    private val windowStart = 60 * minute
    private val windowEnd = 90 * minute

    private fun detectorWithQuietBaseline(): WakeDetector {
        val detector = WakeDetector(windowStart, windowEnd)
        for (i in 1..20) detector.onEpoch(Epoch(i * minute, movement = 0.02, heartRate = 55.0))
        return detector
    }

    @Test
    fun `waits while sleep stays quiet inside the window`() {
        val detector = detectorWithQuietBaseline()
        assertEquals(WakeDecision.Wait, detector.onEpoch(Epoch(windowStart + minute, 0.03, 56.0)))
    }

    @Test
    fun `a movement burst inside the window wakes`() {
        val detector = detectorWithQuietBaseline()
        assertEquals(
            WakeDecision.Wake(WakeReason.LIGHT_SLEEP),
            detector.onEpoch(Epoch(windowStart + minute, 0.3, 56.0)),
        )
    }

    @Test
    fun `a movement burst before the window does not wake`() {
        val detector = detectorWithQuietBaseline()
        assertEquals(WakeDecision.Wait, detector.onEpoch(Epoch(windowStart - minute, 0.3, 56.0)))
    }

    @Test
    fun `a heart-rate rise with some movement wakes`() {
        val detector = detectorWithQuietBaseline()
        assertEquals(
            WakeDecision.Wake(WakeReason.LIGHT_SLEEP),
            detector.onEpoch(Epoch(windowStart + minute, 0.05, 63.0)),
        )
    }

    @Test
    fun `a heart-rate rise while perfectly still does not wake`() {
        val detector = detectorWithQuietBaseline()
        assertEquals(WakeDecision.Wait, detector.onEpoch(Epoch(windowStart + minute, 0.01, 63.0)))
    }

    @Test
    fun `the window end always wakes`() {
        val detector = detectorWithQuietBaseline()
        assertEquals(WakeDecision.Wake(WakeReason.DEADLINE), detector.onEpoch(Epoch(windowEnd, 0.0, null)))
    }

    @Test
    fun `without a baseline only a large movement wakes`() {
        val detector = WakeDetector(windowStart, windowEnd)
        assertEquals(WakeDecision.Wait, detector.onEpoch(Epoch(windowStart + minute, 0.1, null)))
        assertEquals(
            WakeDecision.Wake(WakeReason.LIGHT_SLEEP),
            detector.onEpoch(Epoch(windowStart + 2 * minute, 0.2, null)),
        )
    }

    @Test
    fun `accumulator emits mean movement and heart rate per epoch`() {
        val accumulator = EpochAccumulator(startMillis = 0)
        assertNull(accumulator.addAcceleration(0, 0f, 0f, 9.8f))
        assertNull(accumulator.addAcceleration(1_000, 0f, 0f, 10.0f))
        assertNull(accumulator.addHeartRate(2_000, 60f))
        assertNull(accumulator.addHeartRate(3_000, 0f))
        val epoch = accumulator.addAcceleration(30_000, 0f, 0f, 10.0f)
        assertEquals(30_000L, epoch?.endsAtMillis)
        assertEquals(0.2, epoch!!.movement, 1e-6)
        assertEquals(60.0, epoch.heartRate)
    }

    @Test
    fun `accumulator skips empty epochs after a gap`() {
        val accumulator = EpochAccumulator(startMillis = 0)
        accumulator.addAcceleration(1_000, 0f, 0f, 9.8f)
        assertEquals(30_000L, accumulator.addAcceleration(100_000, 0f, 0f, 9.8f)?.endsAtMillis)
        assertEquals(120_000L, accumulator.addAcceleration(120_000, 0f, 0f, 9.8f)?.endsAtMillis)
    }

    @Test
    fun `night report round trip`() {
        val report = NightReport(
            windowStartMillis = 1,
            windowEndMillis = 2,
            trackingStartMillis = 0,
            wokeAtMillis = 2,
            reason = WakeReason.LIGHT_SLEEP,
            dismissedAtMillis = null,
            epochs = listOf(Epoch(30_000, 0.0123, 57.5), Epoch(60_000, 0.2, null)),
        )
        assertEquals(report, NightReport.decode(report.encode()))
        val status = WatchStatus(true, false, true, 123L, tracking = false, appVersion = "1.0.0")
        assertEquals(status, WatchStatus.decode(status.encode()))
    }
}
