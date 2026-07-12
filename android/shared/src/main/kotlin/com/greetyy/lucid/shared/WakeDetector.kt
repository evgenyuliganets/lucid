package com.greetyy.lucid.shared

import kotlin.math.abs
import kotlin.math.sqrt

/** 30 seconds of wrist data: mean movement and mean heart rate (null without HR). */
data class Epoch(val endsAtMillis: Long, val movement: Double, val heartRate: Double?)

enum class WakeReason { LIGHT_SLEEP, DEADLINE, TEST }

sealed interface WakeDecision {
    data object Wait : WakeDecision
    data class Wake(val reason: WakeReason) : WakeDecision
}

/**
 * Decides the wake moment from the epochs of one night.
 *
 * Epochs before the window build a per-night baseline. Inside the window a
 * movement burst well above that baseline (turning over, a restless moment)
 * or a clear heart-rate rise counts as lighter sleep. At the window end it
 * always wakes.
 *
 * shortcut: thresholds are first guesses, not tuned on real nights; tune them
 * against Samsung's morning stages once nights are logged.
 */
class WakeDetector(private val windowStartMillis: Long, private val windowEndMillis: Long) {
    private val movements = mutableListOf<Double>()
    private val heartRates = mutableListOf<Double>()

    fun onEpoch(epoch: Epoch): WakeDecision {
        if (epoch.endsAtMillis >= windowEndMillis) return WakeDecision.Wake(WakeReason.DEADLINE)
        val lighter = epoch.endsAtMillis >= windowStartMillis && isLighter(epoch)
        movements += epoch.movement
        epoch.heartRate?.let { heartRates += it }
        return if (lighter) WakeDecision.Wake(WakeReason.LIGHT_SLEEP) else WakeDecision.Wait
    }

    private fun isLighter(epoch: Epoch): Boolean {
        if (movements.size < MIN_BASELINE_EPOCHS) {
            return epoch.movement >= MIN_MOVEMENT * NO_BASELINE_FACTOR
        }
        val movementBurst = epoch.movement >= maxOf(MIN_MOVEMENT, median(movements) * MOVEMENT_FACTOR)
        val heartRateRise = epoch.heartRate != null &&
            heartRates.size >= MIN_BASELINE_EPOCHS &&
            epoch.heartRate >= median(heartRates) + HEART_RATE_RISE &&
            epoch.movement >= MIN_MOVEMENT / 2
        return movementBurst || heartRateRise
    }

    companion object {
        /** Mean change of acceleration magnitude (m/s^2) that is clearly a body movement. */
        const val MIN_MOVEMENT = 0.08
        const val MOVEMENT_FACTOR = 3.0
        const val NO_BASELINE_FACTOR = 2.0
        const val HEART_RATE_RISE = 6.0
        const val MIN_BASELINE_EPOCHS = 6

        private fun median(values: List<Double>): Double {
            val sorted = values.sorted()
            val middle = sorted.size / 2
            return if (sorted.size % 2 == 1) sorted[middle] else (sorted[middle - 1] + sorted[middle]) / 2
        }
    }
}

/** Turns accelerometer and heart-rate samples into [Epoch]s of [EPOCH_MILLIS]. */
class EpochAccumulator(startMillis: Long) {
    private var epochEnd = startMillis + EPOCH_MILLIS
    private var lastMagnitude: Double? = null
    private var movementSum = 0.0
    private var movementCount = 0
    private var heartRateSum = 0.0
    private var heartRateCount = 0

    /** Returns the finished epoch when [atMillis] crosses an epoch boundary. */
    fun addAcceleration(atMillis: Long, x: Float, y: Float, z: Float): Epoch? {
        val finished = closeIfDue(atMillis)
        val magnitude = sqrt((x * x + y * y + z * z).toDouble())
        lastMagnitude?.let {
            movementSum += abs(magnitude - it)
            movementCount++
        }
        lastMagnitude = magnitude
        return finished
    }

    fun addHeartRate(atMillis: Long, bpm: Float): Epoch? {
        val finished = closeIfDue(atMillis)
        if (bpm in MIN_BPM..MAX_BPM) {
            heartRateSum += bpm
            heartRateCount++
        }
        return finished
    }

    private fun closeIfDue(atMillis: Long): Epoch? {
        if (atMillis < epochEnd) return null
        val epoch = Epoch(
            endsAtMillis = epochEnd,
            movement = if (movementCount == 0) 0.0 else movementSum / movementCount,
            heartRate = if (heartRateCount == 0) null else heartRateSum / heartRateCount,
        )
        // Skip whole empty epochs after a sensor gap; the next epoch ends after atMillis.
        epochEnd += ((atMillis - epochEnd) / EPOCH_MILLIS + 1) * EPOCH_MILLIS
        movementSum = 0.0
        movementCount = 0
        heartRateSum = 0.0
        heartRateCount = 0
        return epoch
    }

    companion object {
        const val EPOCH_MILLIS = 30_000L
        private const val MIN_BPM = 30f
        private const val MAX_BPM = 220f
    }
}
