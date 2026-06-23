package com.blackstartlabs.aizen

import android.app.AppOpsManager
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.os.Build
import android.os.BatteryManager
import android.os.PowerManager
import android.os.SystemClock
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.aizen.app/hardware_bridge"
    private var flutterChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        StopwatchService.mainActivityInstance = this
        scheduleDailyNotification()

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        flutterChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateHabitWidget" -> {
                    try {
                        val appWidgetManager = AppWidgetManager.getInstance(this)
                        val ids = appWidgetManager.getAppWidgetIds(
                            ComponentName(this, HabitWidgetProvider::class.java)
                        )
                        val intent = Intent(this, HabitWidgetProvider::class.java).apply {
                            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                        }
                        sendBroadcast(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("WIDGET_ERR", e.message, null)
                    }
                }
                "getInstalledApps" -> {
                    val apps = getInstalledAppsList()
                    result.success(apps)
                }
                "checkUsagePermission" -> {
                    val hasPerm = checkUsageStatsPermission()
                    if (!hasPerm) {
                        requestUsageStatsPermission()
                    }
                    result.success(hasPerm)
                }
                "checkOverlayPermission" -> {
                    val hasPerm = checkOverlayDrawPermission()
                    if (!hasPerm) {
                        requestOverlayDrawPermission()
                    }
                    result.success(hasPerm)
                }
                "updateBlacklistData" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    FocusBlockerService.blacklistPackages = packages
                    
                    if (packages.isNotEmpty() && !FocusBlockerService.isServiceRunning) {
                        val intent = Intent(this, FocusBlockerService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                    } else if (packages.isEmpty() && FocusBlockerService.isServiceRunning) {
                        stopService(Intent(this, FocusBlockerService::class.java))
                    }
                    
                    result.success(true)
                }
                "startStopwatchService" -> {
                    val isRunning = call.argument<Boolean>("isRunning") ?: false
                    val elapsedTimeMs = call.argument<Long>("elapsedTimeMs") ?: 0L
                    val intent = Intent(this, StopwatchService::class.java).apply {
                        putExtra("isRunning", isRunning)
                        putExtra("elapsedTimeMs", elapsedTimeMs)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(true)
                }
                "stopStopwatchService" -> {
                    stopService(Intent(this, StopwatchService::class.java))
                    result.success(true)
                }
                "getKernelTelemetry" -> {
                    val telemetry = getKernelTelemetryData()
                    result.success(telemetry)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getInstalledAppsList(): List<Map<String, String>> {
        val pm = packageManager
        val list = pm.getInstalledPackages(0)
        val result = mutableListOf<Map<String, String>>()
        for (pkg in list) {
            val appInfo = pkg.applicationInfo ?: continue
            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            if (!isSystem) {
                val label = appInfo.loadLabel(pm).toString()
                result.add(mapOf(
                    "name" to label,
                    "packageName" to pkg.packageName
                ))
            }
        }
        return result
    }

    private fun checkUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(intent)
    }

    private fun checkOverlayDrawPermission(): Boolean {
        return Settings.canDrawOverlays(this)
    }

    private fun requestOverlayDrawPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            ).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
        }
    }

    private var lastBatteryLevel = -1
    private var lastTelemetryTimestamp = 0L
    private var activeLevelDrop = 0
    private var activeTimeMs = 0L
    private var idleLevelDrop = 0
    private var idleTimeMs = 0L
    private var isTelemetryInitialized = false

    private fun initTelemetryStats() {
        if (isTelemetryInitialized) return
        val prefs = getSharedPreferences("telemetry_stats", Context.MODE_PRIVATE)
        activeLevelDrop = prefs.getInt("active_drop", 0)
        activeTimeMs = prefs.getLong("active_time", 0L)
        idleLevelDrop = prefs.getInt("idle_drop", 0)
        idleTimeMs = prefs.getLong("idle_time", 0L)
        isTelemetryInitialized = true
    }

    private fun updateDrainTelemetry(currentLevel: Int, isScreenOn: Boolean) {
        initTelemetryStats()
        val now = System.currentTimeMillis()
        if (lastBatteryLevel != -1 && currentLevel != lastBatteryLevel) {
            val drop = lastBatteryLevel - currentLevel
            val duration = now - lastTelemetryTimestamp
            if (drop > 0 && duration > 0) {
                if (isScreenOn) {
                    activeLevelDrop += drop
                    activeTimeMs += duration
                } else {
                    idleLevelDrop += drop
                    idleTimeMs += duration
                }
                val prefs = getSharedPreferences("telemetry_stats", Context.MODE_PRIVATE)
                prefs.edit().apply {
                    putInt("active_drop", activeLevelDrop)
                    putLong("active_time", activeTimeMs)
                    putInt("idle_drop", idleLevelDrop)
                    putLong("idle_time", idleTimeMs)
                    apply()
                }
            }
        }
        lastBatteryLevel = currentLevel
        lastTelemetryTimestamp = now
    }

    private fun getActiveDrainRate(): Double {
        if (activeTimeMs < 1000 * 60) return 12.22
        val hours = activeTimeMs.toDouble() / (1000 * 60 * 60)
        val rate = activeLevelDrop.toDouble() / hours
        return if (rate > 0.0) rate else 12.22
    }

    private fun getIdleDrainRate(): Double {
        if (idleTimeMs < 1000 * 60) return 1.05
        val hours = idleTimeMs.toDouble() / (1000 * 60 * 60)
        val rate = idleLevelDrop.toDouble() / hours
        return if (rate > 0.0) rate else 1.05
    }

    private fun getKernelTelemetryData(): Map<String, Any> {
        val bm = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        
        var currentNow = 0L
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val microAmps = bm.getLongProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
            currentNow = microAmps / 1000 // Convert to mA
            if (currentNow < 0) {
                currentNow = -currentNow
            }
        }
        if (currentNow == 0L) {
            currentNow = 693L
        }
        
        val elapsedRealtime = SystemClock.elapsedRealtime()
        val uptimeMillis = SystemClock.uptimeMillis()
        val deepSleepMs = elapsedRealtime - uptimeMillis
        val awakeMs = uptimeMillis
        
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        val isScreenOn = pm.isInteractive

        val batteryLevel = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            35
        }

        updateDrainTelemetry(batteryLevel, isScreenOn)
        val activeDrain = getActiveDrainRate()
        val idleDrain = getIdleDrainRate()

        return mapOf(
            "currentNow" to currentNow,
            "deepSleepMs" to deepSleepMs,
            "awakeMs" to awakeMs,
            "isScreenOn" to isScreenOn,
            "activeDrain" to activeDrain,
            "idleDrain" to idleDrain,
            "uptimeMs" to elapsedRealtime
        )
    }

    private fun scheduleDailyNotification() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
        val intent = Intent(this, NotificationReceiver::class.java)
        val pendingIntent = android.app.PendingIntent.getBroadcast(
            this,
            1001,
            intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            } else {
                android.app.PendingIntent.FLAG_UPDATE_CURRENT
            }
        )

        val triggerTime = System.currentTimeMillis() + 24 * 60 * 60 * 1000L
        alarmManager.setRepeating(
            android.app.AlarmManager.RTC_WAKEUP,
            triggerTime,
            android.app.AlarmManager.INTERVAL_DAY,
            pendingIntent
        )
    }

    fun notifyStopwatchAction(action: String) {
        flutterChannel?.invokeMethod("onStopwatchAction", action)
    }

    override fun onDestroy() {
        StopwatchService.mainActivityInstance = null
        super.onDestroy()
    }
}
