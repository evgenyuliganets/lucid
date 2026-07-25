package com.greetyy.lucid.wear

import android.Manifest
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.content.Context
import android.os.Bundle
import android.provider.Settings
import android.text.format.DateFormat
import android.text.format.DateUtils
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.foundation.lazy.rememberScalingLazyListState
import androidx.wear.compose.material3.Button
import androidx.wear.compose.material3.FilledTonalButton
import androidx.wear.compose.material3.ListHeader
import androidx.wear.compose.material3.MaterialTheme
import androidx.wear.compose.material3.Text
import com.greetyy.lucid.shared.WakeWindow
import java.time.Instant
import java.util.Date

/** Shows the synced alarm and asks for what the watch still needs. */
class MainActivity : ComponentActivity() {
    private val screen = mutableStateOf(WatchScreenState())

    private val askPermission = registerForActivityResult(ActivityResultContracts.RequestPermission()) {
        refresh()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                val state by screen
                WatchScreen(
                    state = state,
                    onAllowNotifications = { askPermission.launch(Manifest.permission.POST_NOTIFICATIONS) },
                    onAllowAlarmScreen = ::openFullScreenSettings,
                    onUseHeartRate = ::askHeartRate,
                    onTest = { NightService.test(this) },
                )
            }
        }
    }

    override fun onResume() {
        super.onResume()
        refresh()
        PhoneLink.pullSettings(this) { refresh() }
    }

    private fun refresh() {
        val prefs = WatchPrefs(this)
        screen.value = WatchScreenState(
            window = prefs.armedWindow,
            tracking = NightService.trackingWindowEnd != null,
            notificationsAllowed = PhoneLink.notificationsAllowed(this),
            fullScreenAllowed = PhoneLink.fullScreenAllowed(this),
            heartRateForeground = HeartRatePermission.foregroundGranted(this),
            heartRateAllowed = HeartRatePermission.allowed(this),
        )
        PhoneLink.publishStatus(this)
    }

    private fun askHeartRate() {
        // Background access can only be asked for after the foreground permission.
        val permission = if (HeartRatePermission.foregroundGranted(this)) {
            HeartRatePermission.background
        } else {
            HeartRatePermission.foreground
        }
        askPermission.launch(permission)
    }

    private fun openFullScreenSettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return
        val intent = Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, Uri.parse("package:$packageName"))
        runCatching { startActivity(intent) }.onFailure {
            startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")))
        }
    }
}

data class WatchScreenState(
    val window: WakeWindow? = null,
    val tracking: Boolean = false,
    val notificationsAllowed: Boolean = true,
    val fullScreenAllowed: Boolean = true,
    val heartRateForeground: Boolean = false,
    val heartRateAllowed: Boolean = false,
)

@Composable
private fun WatchScreen(
    state: WatchScreenState,
    onAllowNotifications: () -> Unit,
    onAllowAlarmScreen: () -> Unit,
    onUseHeartRate: () -> Unit,
    onTest: () -> Unit,
) {
    val listState = rememberScalingLazyListState()
    ScalingLazyColumn(modifier = Modifier.fillMaxSize(), state = listState) {
        item { ListHeader { Text(stringResource(R.string.app_name)) } }
        item { AlarmSummary(state) }
        if (!state.notificationsAllowed) {
            item {
                Button(
                    onClick = onAllowNotifications,
                    modifier = Modifier.fillMaxWidth(),
                    secondaryLabel = { Text(stringResource(R.string.allow_notifications_hint)) },
                ) { Text(stringResource(R.string.allow_notifications)) }
            }
        }
        if (!state.fullScreenAllowed) {
            item {
                Button(
                    onClick = onAllowAlarmScreen,
                    modifier = Modifier.fillMaxWidth(),
                    secondaryLabel = { Text(stringResource(R.string.allow_alarm_screen_hint)) },
                ) { Text(stringResource(R.string.allow_alarm_screen)) }
            }
        }
        item {
            when {
                state.heartRateAllowed -> FilledTonalButton(
                    onClick = {},
                    modifier = Modifier.fillMaxWidth(),
                    enabled = false,
                ) { Text(stringResource(R.string.heart_rate_on)) }
                state.heartRateForeground -> FilledTonalButton(
                    onClick = onUseHeartRate,
                    modifier = Modifier.fillMaxWidth(),
                    secondaryLabel = { Text(stringResource(R.string.heart_rate_background_hint)) },
                ) { Text(stringResource(R.string.heart_rate_background)) }
                else -> FilledTonalButton(
                    onClick = onUseHeartRate,
                    modifier = Modifier.fillMaxWidth(),
                    secondaryLabel = { Text(stringResource(R.string.use_heart_rate_hint)) },
                ) { Text(stringResource(R.string.use_heart_rate)) }
            }
        }
        item {
            FilledTonalButton(
                onClick = onTest,
                modifier = Modifier.fillMaxWidth(),
                enabled = !state.tracking,
                secondaryLabel = { Text(stringResource(R.string.test_alarm_hint)) },
            ) { Text(stringResource(R.string.test_alarm)) }
        }
    }
}

@Composable
private fun AlarmSummary(state: WatchScreenState) {
    val window = state.window
    val context = LocalContext.current
    val title = if (window == null) {
        stringResource(R.string.no_alarm)
    } else {
        val format = DateFormat.getTimeFormat(context)
        stringResource(
            R.string.window_label,
            format.format(Date.from(window.start)),
            format.format(Date.from(window.end)),
        )
    }
    val detail = when {
        window == null -> stringResource(R.string.no_alarm_hint)
        state.tracking -> stringResource(R.string.tracking)
        else -> "${dayLabel(context, window.end)} · ${stringResource(R.string.armed_hint)}"
    }
    Column(modifier = Modifier.padding(vertical = 4.dp)) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth(),
        )
        Text(
            text = detail,
            style = MaterialTheme.typography.bodySmall,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth(),
        )
    }
}

private fun dayLabel(context: Context, end: Instant): String {
    val millis = end.toEpochMilli()
    return when {
        DateUtils.isToday(millis) -> context.getString(R.string.today)
        DateUtils.isToday(millis - DateUtils.DAY_IN_MILLIS) -> context.getString(R.string.tomorrow)
        else -> DateUtils.formatDateTime(context, millis, DateUtils.FORMAT_SHOW_WEEKDAY)
    }
}
