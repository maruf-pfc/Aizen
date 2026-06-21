package com.blackstartlabs.aizen

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.aizen.app/hardware_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
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
}
