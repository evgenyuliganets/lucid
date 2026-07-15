package com.greetyy.lucid

import android.app.Activity
import com.samsung.android.sdk.health.data.HealthDataService
import com.samsung.android.sdk.health.data.data.HealthDataPoint
import com.samsung.android.sdk.health.data.error.AuthorizationException
import com.samsung.android.sdk.health.data.error.ErrorCode
import com.samsung.android.sdk.health.data.error.HealthDataException
import com.samsung.android.sdk.health.data.error.ResolvablePlatformException
import com.samsung.android.sdk.health.data.permission.AccessType
import com.samsung.android.sdk.health.data.permission.Permission
import com.samsung.android.sdk.health.data.request.DataType
import com.samsung.android.sdk.health.data.request.DataTypes
import com.samsung.android.sdk.health.data.request.LocalTimeFilter
import com.samsung.android.sdk.health.data.request.Ordering
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId

/**
 * `lucid/samsung`: Samsung Health's sleep records (Samsung Health Data SDK),
 * read in the morning to show the night and check Lucid's wake moment.
 * Samsung creates them only after the user wakes up.
 */
class SamsungChannel(
    messenger: BinaryMessenger,
    private val activity: Activity,
    private val scope: CoroutineScope,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, NAME).also { it.setMethodCallHandler(this) }
    private val sleepRead = setOf(Permission.of(DataTypes.SLEEP, AccessType.READ))

    fun dispose() = channel.setMethodCallHandler(null)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> scope.launch { result.success(status()) }
            "connect" -> scope.launch { result.success(connect()) }
            "readSleep" -> {
                val from = (call.argument<Number>("from"))?.toLong()
                val to = (call.argument<Number>("to"))?.toLong()
                if (from == null || to == null || from >= to) {
                    result.error("invalidRange", "from must be before to", null)
                } else {
                    scope.launch { readSleep(from, to, result) }
                }
            }
            else -> result.notImplemented()
        }
    }

    private suspend fun status(): String = try {
        val granted = HealthDataService.getStore(activity).getGrantedPermissions(sleepRead)
        if (granted.containsAll(sleepRead)) READY else PERMISSION_NEEDED
    } catch (error: HealthDataException) {
        statusOf(error)
    }

    private suspend fun connect(): String = try {
        HealthDataService.getStore(activity).requestPermissions(sleepRead, activity)
        status()
    } catch (error: ResolvablePlatformException) {
        // Samsung Health must be installed, updated or opened once; it shows its own screen.
        if (error.hasResolution) error.resolve(activity)
        statusOf(error)
    } catch (error: HealthDataException) {
        statusOf(error)
    }

    private suspend fun readSleep(from: Long, to: Long, result: MethodChannel.Result) {
        try {
            val zone = ZoneId.systemDefault()
            val request = DataTypes.SLEEP.readDataRequestBuilder
                .setLocalTimeFilter(
                    LocalTimeFilter.of(
                        LocalDateTime.ofInstant(Instant.ofEpochMilli(from), zone),
                        LocalDateTime.ofInstant(Instant.ofEpochMilli(to), zone),
                    ),
                )
                .setOrdering(Ordering.DESC)
                .build()
            val points = HealthDataService.getStore(activity).readData(request).dataList
            result.success(points.map(::sleepMap))
        } catch (error: HealthDataException) {
            result.error(statusOf(error), "Samsung Health could not be read", null)
        }
    }

    private fun sleepMap(point: HealthDataPoint): Map<String, Any?> = mapOf(
        "start" to point.startTime.toEpochMilli(),
        "end" to point.endTime?.toEpochMilli(),
        "score" to point.getValue(DataType.SleepType.SLEEP_SCORE),
        "sessions" to point.getValue(DataType.SleepType.SESSIONS).orEmpty().map { session ->
            mapOf(
                "start" to session.startTime.toEpochMilli(),
                "end" to session.endTime.toEpochMilli(),
                "stages" to session.stages.orEmpty().map { stage ->
                    mapOf(
                        "start" to stage.startTime.toEpochMilli(),
                        "end" to stage.endTime.toEpochMilli(),
                        "stage" to stage.stage.name.lowercase(),
                    )
                },
            )
        },
    )

    /** One stable code per failure; Dart shows the matching instructions. */
    private fun statusOf(error: HealthDataException): String = when {
        error is AuthorizationException -> DEVELOPER_MODE_NEEDED
        error.errorCode == ErrorCode.ERR_PLATFORM_NOT_INSTALLED -> NOT_INSTALLED
        error.errorCode == ErrorCode.ERR_OLD_VERSION_PLATFORM -> UPDATE_NEEDED
        error.errorCode == ErrorCode.ERR_PLATFORM_DISABLED -> DISABLED
        error.errorCode == ErrorCode.ERR_PLATFORM_NOT_INITIALIZED -> NOT_INITIALIZED
        error.errorCode == ErrorCode.ERR_NO_USER_PERMISSION -> PERMISSION_NEEDED
        error.errorCode == ErrorCode.ERR_INVALID_PLATFORM_SIGNATURE ||
            error.errorCode == ErrorCode.ERR_ACCESS_CONTROL -> DEVELOPER_MODE_NEEDED
        else -> UNAVAILABLE
    }

    companion object {
        const val NAME = "lucid/samsung"
        private const val READY = "ready"
        private const val PERMISSION_NEEDED = "permissionNeeded"
        private const val DEVELOPER_MODE_NEEDED = "developerModeNeeded"
        private const val NOT_INSTALLED = "notInstalled"
        private const val UPDATE_NEEDED = "updateNeeded"
        private const val DISABLED = "disabled"
        private const val NOT_INITIALIZED = "notInitialized"
        private const val UNAVAILABLE = "unavailable"
    }
}
