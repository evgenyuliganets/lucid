package com.greetyy.lucid

import android.app.Activity
import android.graphics.Color
import android.os.Bundle
import android.text.format.DateFormat
import android.util.TypedValue
import android.view.Gravity
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import java.lang.ref.WeakReference
import java.util.Date

/** The phone's alarm screen over the lock screen: time, Wake up, Snooze. */
class RingActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        current = WeakReference(this)
        val dp = resources.displayMetrics.density
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#1B1630"))
            setPadding((32 * dp).toInt(), 0, (32 * dp).toInt(), 0)
        }
        layout.addView(text(DateFormat.getTimeFormat(this).format(Date()), 64f))
        layout.addView(text(getString(R.string.ring_title), 24f))
        val testRing = PhoneStore(this).ringingWindowEnd == 0L
        layout.addView(text(getString(if (testRing) R.string.ring_test else R.string.ring_text), 16f))
        layout.addView(
            button(getString(R.string.dismiss)) { PhoneAlarm.dismiss(this) },
            LinearLayout.LayoutParams(MATCH_PARENT, (64 * dp).toInt()).apply { topMargin = (48 * dp).toInt() },
        )
        layout.addView(
            button(getString(R.string.snooze)) { PhoneAlarm.snooze(this) },
            LinearLayout.LayoutParams(MATCH_PARENT, (56 * dp).toInt()).apply { topMargin = (12 * dp).toInt() },
        )
        setContentView(layout)
    }

    override fun onResume() {
        super.onResume()
        // Dismissed elsewhere (the watch or the notification) while hidden.
        if (PhoneStore(this).ringingWindowEnd < 0) finish()
    }

    override fun onDestroy() {
        if (current?.get() === this) current = null
        super.onDestroy()
    }

    private fun text(value: String, sizeSp: Float) = TextView(this).apply {
        text = value
        setTextColor(Color.WHITE)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, sizeSp)
        gravity = Gravity.CENTER
        layoutParams = LinearLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT)
    }

    private fun button(label: String, onClick: () -> Unit) = Button(this).apply {
        text = label
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
        setOnClickListener {
            onClick()
            finish()
        }
    }

    companion object {
        private var current: WeakReference<RingActivity>? = null

        fun closeAll() {
            current?.get()?.runOnUiThread { current?.get()?.finish() }
        }
    }
}
