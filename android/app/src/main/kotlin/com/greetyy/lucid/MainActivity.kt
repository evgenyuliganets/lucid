package com.greetyy.lucid

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel

class MainActivity : FlutterActivity() {
    private val scope = MainScope()
    private var alarmChannel: AlarmChannel? = null
    private var samsungChannel: SamsungChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        alarmChannel = AlarmChannel(messenger, this, scope)
        samsungChannel = SamsungChannel(messenger, this, scope)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        alarmChannel?.dispose()
        samsungChannel?.dispose()
        alarmChannel = null
        samsungChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }

    @Deprecated("Activity result API is not used by FlutterActivity")
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == AlarmChannel.PERMISSION_REQUEST) alarmChannel?.onPermissionResult()
    }
}
