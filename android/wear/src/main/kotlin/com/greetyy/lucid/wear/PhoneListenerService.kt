package com.greetyy.lucid.wear

import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.WearableListenerService
import com.greetyy.lucid.shared.AlarmSettings
import com.greetyy.lucid.shared.Sync

/** Receives the alarm and phone-side dismissals from the phone app. */
class PhoneListenerService : WearableListenerService() {
    override fun onDataChanged(events: DataEventBuffer) {
        events.filter { it.type == DataEvent.TYPE_CHANGED }.forEach { event ->
            val item = event.dataItem
            val value = DataMapItem.fromDataItem(item).dataMap.getString(Sync.KEY_VALUE) ?: return@forEach
            when (item.uri.path) {
                Sync.SETTINGS_PATH -> AlarmSettings.decode(value)?.let {
                    WatchPrefs(this).settings = it
                    NightSchedule.arm(this)
                }
                Sync.PHONE_DISMISSED_PATH -> value.toLongOrNull()?.let { NightService.phoneDismissed(this, it) }
            }
        }
    }
}
