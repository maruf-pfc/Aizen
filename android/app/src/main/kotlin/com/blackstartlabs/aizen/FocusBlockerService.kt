package com.blackstartlabs.aizen

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
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
        super.onCreate();
        isServiceRunning = true
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildForegroundNotification())
        startAppMonitoring()
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

    private fun checkForegroundApp() {
        val currentApp = getForegroundPackageName() ?: return

        mainHandler.post {
            val isBlacklisted = blacklistPackages.contains(currentApp)
            if (isBlacklisted) {
                // Check failsafe: 60 minutes lockout maximum limit
                if (isOverlayShown) {
                    val duration = System.currentTimeMillis() - overlayShownTime
                    if (duration > 60 * 60 * 1000) { // 60 minutes
                        Log.w(TAG, "60-minute failsafe triggered: removing overlay lockout.")
                        removeOverlay()
                        return@post
                    }
                }
                showOverlay()
            } else {
                removeOverlay()
            }
        }
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

    private fun showOverlay() {
        if (isOverlayShown) return

        try {
            val layoutParams = WindowManager.LayoutParams().apply {
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
                setBackgroundColor(Color.parseColor("#000000")) // AMOLED Pure Black
            }

            val textWidget = TextView(this).apply {
                text = "AIZEN\n\nFocus Guardian Locked\nLimit Exceeded"
                setTextColor(Color.parseColor("#7C4DFF")) // Neon Violet Accent
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
                gravity = Gravity.CENTER
                setLineSpacing(0f, 1.3f)
            }

            val frameParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER
            )
            overlayView?.addView(textWidget, frameParams)

            windowManager?.addView(overlayView, layoutParams)
            isOverlayShown = true
            overlayShownTime = System.currentTimeMillis()
            Log.d(TAG, "Overlay injected successfully via WindowManager.")
        } catch (e: Exception) {
            Log.e(TAG, "Error injecting WindowManager overlay: ${e.message}", e)
        }
    }

    private fun removeOverlay() {
        if (!isOverlayShown) return

        try {
            overlayView?.let {
                windowManager?.removeView(it)
            }
            overlayView = null
            isOverlayShown = false
            Log.d(TAG, "Overlay removed successfully.")
        } catch (e: Exception) {
            Log.e(TAG, "Error removing WindowManager overlay: ${e.message}", e)
        }
    }
}
