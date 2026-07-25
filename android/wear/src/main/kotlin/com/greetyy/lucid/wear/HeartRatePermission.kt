package com.greetyy.lucid.wear

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat

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
