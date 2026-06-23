package com.blackstartlabs.aizen

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.BatteryManager
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.core.app.NotificationCompat
import java.util.Timer
import java.util.TimerTask

class FocusBlockerService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: FrameLayout? = null
    private var isOverlayShown = false
    private var overlayShownTime = 0L

    private var monitorTimer: Timer? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // Escalating Friction hold state
    private var bypassedPackage: String? = null
    private var bypassedUntil = 0L
    private var isHolding = false
    private var holdProgress = 0
    private val holdDurationMs = 5000L

    // Battery / Temp Safety Receiver
    private var batteryReceiver: BroadcastReceiver? = null

    companion object {
        private const val TAG = "FocusBlockerService"
        private const val CHANNEL_ID = "focus_guardian_channel"
        private const val NOTIFICATION_ID = 1004

        @Volatile
        var blacklistPackages: List<String> = emptyList()

        @Volatile
        var isServiceRunning = false
    }

    override fun onCreate() {
        super.onCreate()
        isServiceRunning = true
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildForegroundNotification())
        startAppMonitoring()
        registerSafetyReceiver()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        isServiceRunning = false
        stopAppMonitoring()
        unregisterSafetyReceiver()
        removeOverlay()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Focus Guardian Active Monitoring",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Background service ensuring restricted apps are blocked."
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildForegroundNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Focus Guardian Active")
            .setContentText("Aizen is keeping you locked into your goals.")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

    private fun startAppMonitoring() {
        monitorTimer = Timer()
        monitorTimer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                checkForegroundApp()
            }
        }, 0, 500) // check every 500ms
    }

    private fun stopAppMonitoring() {
        monitorTimer?.cancel()
        monitorTimer = null
    }

    private fun registerSafetyReceiver() {
        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        batteryReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                val temp = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) // in tenths of a degree Celsius
                
                val pct = if (level >= 0 && scale > 0) (level * 100f / scale) else 100f
                val tempC = temp / 10f
                
                // Trigger auto-save if battery < 15% or temperature > 45 degrees Celsius
                if (pct < 15f || tempC > 45f) {
                    saveSessionProgressSafety(pct, tempC)
                }
            }
        }
        registerReceiver(batteryReceiver, filter)
    }

    private fun unregisterSafetyReceiver() {
        batteryReceiver?.let {
            unregisterReceiver(it)
            batteryReceiver = null
        }
    }

    private fun saveSessionProgressSafety(batteryPercent: Float, tempC: Float) {
        val prefs = getSharedPreferences("aizen_focus_safety", Context.MODE_PRIVATE)
        prefs.edit().apply {
            putBoolean("session_autosaved", true)
            putLong("autosave_timestamp", System.currentTimeMillis())
            putString("autosave_reason", "Battery: ${batteryPercent.toInt()}%, Temp: ${tempC}C")
            apply()
        }
        Log.w(TAG, "Safety Auto-Save triggered: Battery is ${batteryPercent}% and Temp is ${tempC}C. State persisted.")
    }

    private fun checkForegroundApp() {
        try {
            // Check 60-minute automatic emergency auto-unlock failsafe
            if (isOverlayShown && (System.currentTimeMillis() - overlayShownTime >= 3600000)) {
                Log.w(TAG, "Failsafe auto-unlock: Overlay active for 60 minutes. Clearing overlay for safety.")
                mainHandler.post {
                    triggerFailsafeSafetyReset()
                }
                return
            }

            val currentApp = getForegroundPackageName() ?: return

            // Check if app bypass is active
            if (currentApp == bypassedPackage && System.currentTimeMillis() < bypassedUntil) {
                mainHandler.post {
                    removeOverlay()
                }
                return
            }

            mainHandler.post {
                try {
                    val isBlacklisted = blacklistPackages.contains(currentApp)
                    if (isBlacklisted) {
                        showOverlay(currentApp)
                    } else {
                        removeOverlay()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error processing package check callback: ${e.message}", e)
                    triggerFailsafeSafetyReset()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking foreground app package: ${e.message}", e)
            mainHandler.post {
                triggerFailsafeSafetyReset()
            }
        }
    }

    private fun triggerFailsafeSafetyReset() {
        try {
            Toast.makeText(
                this,
                "Focus guardian failsafe triggered: temporary auto-unlock active.",
                Toast.LENGTH_LONG
            ).show()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to display failsafe Toast: ${e.message}")
        }
        bypassedPackage = null
        bypassedUntil = 0
        blacklistPackages = emptyList()
        removeOverlay()
    }

    private fun getForegroundPackageName(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 1000 * 60 // 1 minute window

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
        var foregroundApp: String? = null
        val event = UsageEvents.Event()

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                foregroundApp = event.packageName
            }
        }
        return foregroundApp
    }

    private fun showOverlay(currentApp: String) {
        if (isOverlayShown) return

        try {
            val windowParams = WindowManager.LayoutParams().apply {
                type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE
                }
                flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                        WindowManager.LayoutParams.FLAG_FULLSCREEN
                format = PixelFormat.TRANSLUCENT
                width = WindowManager.LayoutParams.MATCH_PARENT
                height = WindowManager.LayoutParams.MATCH_PARENT
                gravity = Gravity.CENTER
            }

            overlayView = FrameLayout(this).apply {
                setBackgroundColor(Color.parseColor("#061012")) // Sleek Koinly Dark Base
            }

            val container = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setPadding(60, 60, 60, 60)
            }

            val titleText = TextView(this).apply {
                text = "FOCUS GUARDIAN"
                setTextColor(Color.parseColor("#7C4DFF")) // Neon Violet
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
            }

            val subText = TextView(this).apply {
                text = "This application is currently restricted.\nEmergency 60-minute auto-unlock active."
                setTextColor(Color.parseColor("#8A9F9F")) // Dark Teal Accent
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
                gravity = Gravity.CENTER
                setPadding(0, 16, 0, 48)
            }

            val progressBar = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal).apply {
                max = 100
                progress = 0
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, 32)
                }
            }

            val holdButton = TextView(this).apply {
                text = "HOLD TO BYPASS (5s)"
                setTextColor(Color.parseColor("#00C7D8")) // Cyan Accent
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
                setPadding(48, 32, 48, 32)
                
                val shape = android.graphics.drawable.GradientDrawable().apply {
                    setColor(Color.parseColor("#102528")) // Surface mid
                    cornerRadius = 32f
                    setStroke(2, Color.parseColor("#00C7D8"))
                }
                background = shape
            }

            holdButton.setOnTouchListener { _, event ->
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        isHolding = true
                        holdProgress = 0
                        progressBar.progress = 0
                        startHoldTimer(progressBar, currentApp)
                        true
                    }
                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                        isHolding = false
                        holdProgress = 0
                        progressBar.progress = 0
                        true
                    }
                    else -> false
                }
            }

            container.addView(titleText)
            container.addView(subText)
            container.addView(progressBar)
            container.addView(holdButton)

            val frameParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER
            )
            overlayView?.addView(container, frameParams)

            windowManager?.addView(overlayView, windowParams)
            isOverlayShown = true
            overlayShownTime = System.currentTimeMillis()
            Log.d(TAG, "Overlay injected successfully via WindowManager.")
        } catch (e: Exception) {
            Log.e(TAG, "Error injecting WindowManager overlay: ${e.message}", e)
            triggerFailsafeSafetyReset()
        }
    }

    private fun startHoldTimer(progressBar: ProgressBar, packageName: String) {
        val checkInterval = 100L
        val totalSteps = (holdDurationMs / checkInterval).toInt()
        var currentStep = 0

        val runnable = object : Runnable {
            override fun run() {
                if (!isHolding || !isOverlayShown) return
                currentStep++
                holdProgress = (currentStep * 100) / totalSteps
                progressBar.progress = holdProgress

                if (holdProgress >= 100) {
                    // Success! Bypass app for 10 minutes
                    bypassedPackage = packageName
                    bypassedUntil = System.currentTimeMillis() + 10 * 60 * 1000 // 10 minutes
                    removeOverlay()
                    Toast.makeText(this@FocusBlockerService, "Bypassed restriction for 10 minutes", Toast.LENGTH_SHORT).show()
                } else {
                    mainHandler.postDelayed(this, checkInterval)
                }
            }
        }
        mainHandler.postDelayed(runnable, checkInterval)
    }

    private fun removeOverlay() {
        if (!isOverlayShown) return

        try {
            overlayView?.let {
                windowManager?.removeView(it)
            }
            overlayView = null
            isOverlayShown = false
            isHolding = false
            holdProgress = 0
            Log.d(TAG, "Overlay removed successfully.")
        } catch (e: Exception) {
            Log.e(TAG, "Error removing WindowManager overlay: ${e.message}", e)
        }
    }
}
