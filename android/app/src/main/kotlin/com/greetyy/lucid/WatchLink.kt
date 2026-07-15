package com.greetyy.lucid

import android.content.Context
import com.google.android.gms.wearable.CapabilityClient
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import com.google.android.gms.wearable.WearableListenerService
import com.greetyy.lucid.shared.AlarmSettings
import com.greetyy.lucid.shared.NightReport
import com.greetyy.lucid.shared.Sync
import com.greetyy.lucid.shared.WatchStatus
import kotlinx.coroutines.tasks.await

/** The phone side of the Wear Data Layer link to the watch app. */
object WatchLink {
    fun pushSettings(context: Context, settings: AlarmSettings) =
        put(context, Sync.SETTINGS_PATH, settings.encode())

    fun sendPhoneDismissed(context: Context, windowEnd: Long) =
        put(context, Sync.PHONE_DISMISSED_PATH, windowEnd.toString())

    /** Paired watch: connected now, and whether Lucid is installed on it. */
    data class WatchInfo(val connected: Boolean, val installed: Boolean, val name: String?)

    suspend fun watchInfo(context: Context): WatchInfo {
        val nodes = runCatching { Wearable.getNodeClient(context).connectedNodes.await() }.getOrDefault(emptyList())
        val installedNodes = runCatching {
            Wearable.getCapabilityClient(context)
                .getCapability(Sync.WATCH_CAPABILITY, CapabilityClient.FILTER_ALL)
                .await()
                .nodes
        }.getOrDefault(emptySet())
        val watch = installedNodes.firstOrNull() ?: nodes.firstOrNull()
        return WatchInfo(
            connected = nodes.isNotEmpty(),
            installed = installedNodes.isNotEmpty(),
            name = watch?.displayName,
        )
    }

    private fun put(context: Context, path: String, value: String) {
        val request = PutDataMapRequest.create(path).apply {
            dataMap.putString(Sync.KEY_VALUE, value)
            dataMap.putLong(Sync.KEY_SENT_AT, System.currentTimeMillis())
        }.asPutDataRequest().setUrgent()
        Wearable.getDataClient(context).putDataItem(request)
    }
}

/** Receives the watch's status, night reports and watch-side dismissals. */
class WatchListenerService : WearableListenerService() {
    override fun onDataChanged(events: DataEventBuffer) {
        events.filter { it.type == DataEvent.TYPE_CHANGED }.forEach { event ->
            val item = event.dataItem
            val value = DataMapItem.fromDataItem(item).dataMap.getString(Sync.KEY_VALUE) ?: return@forEach
            val path = item.uri.path.orEmpty()
            when {
                path == Sync.WATCH_STATUS_PATH -> WatchStatus.decode(value)?.let { PhoneStore(this).saveWatchStatus(it) }
                path.startsWith(Sync.NIGHT_PATH_PREFIX) -> NightReport.decode(value)?.let { PhoneStore(this).saveNight(it) }
                path == Sync.WATCH_DISMISSED_PATH -> value.toLongOrNull()?.let { PhoneAlarm.watchDismissed(this, it) }
            }
        }
        LucidEvents.changed()
    }
}
