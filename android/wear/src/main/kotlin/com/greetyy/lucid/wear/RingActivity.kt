package com.greetyy.lucid.wear

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.wear.compose.material3.Button
import androidx.wear.compose.material3.FilledTonalButton
import androidx.wear.compose.material3.MaterialTheme
import androidx.wear.compose.material3.Text
import com.greetyy.lucid.shared.WakeReason
import java.text.DateFormat
import java.util.Date

/** The alarm screen; it closes itself when the ring ends anywhere. */
class RingActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setContent {
            MaterialTheme {
                val reason by NightService.ringing.collectAsStateWithLifecycle()
                LaunchedEffect(reason) { if (reason == null) finish() }
                reason?.let {
                    RingScreen(
                        reason = it,
                        onDismiss = { NightService.command(this, NightService.ACTION_DISMISS) },
                        onSnooze = { NightService.command(this, NightService.ACTION_SNOOZE) },
                    )
                }
            }
        }
    }
}

@Composable
private fun RingScreen(reason: WakeReason, onDismiss: () -> Unit, onSnooze: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize().padding(horizontal = 20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Text(
            text = DateFormat.getTimeInstance(DateFormat.SHORT).format(Date()),
            style = MaterialTheme.typography.displayMedium,
        )
        Text(text = stringResource(R.string.ring_title), style = MaterialTheme.typography.titleMedium)
        Text(
            text = stringResource(ringMessage(reason)),
            style = MaterialTheme.typography.bodySmall,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(8.dp))
        Button(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) {
            Text(stringResource(R.string.dismiss))
        }
        if (reason != WakeReason.TEST) {
            Spacer(Modifier.height(4.dp))
            FilledTonalButton(onClick = onSnooze, modifier = Modifier.fillMaxWidth()) {
                Text(stringResource(R.string.snooze))
            }
        }
    }
}

fun ringMessage(reason: WakeReason): Int = when (reason) {
    WakeReason.LIGHT_SLEEP -> R.string.ring_light_sleep
    WakeReason.DEADLINE -> R.string.ring_deadline
    WakeReason.TEST -> R.string.ring_test
}
