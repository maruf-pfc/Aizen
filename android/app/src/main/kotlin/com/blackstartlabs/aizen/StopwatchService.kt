package com.blackstartlabs.aizen

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject

class StopwatchService : Service() {

    companion object {
        const val TAG = "StopwatchService"
        const val CHANNEL_ID = "stopwatch_service_channel"
        const val NOTIFICATION_ID = 1005

        const val ACTION_PLAY_PAUSE = "com.blackstartlabs.aizen.stopwatch.PLAY_PAUSE"
        const val ACTION_LAP = "com.blackstartlabs.aizen.stopwatch.LAP"

        var isRunning = false
        var startTimeMs = 0L
        var elapsedTimeMs = 0L

        // Reference to main activity for notifying Flutter
        var mainActivityInstance: MainActivity? = null
    }

    private var receiver: BroadcastReceiver? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        registerActionsReceiver()
        updateNotification()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent != null) {
            val isRunningParam = intent.getBooleanExtra("isRunning", false)
            val elapsedParam = intent.getLongExtra("elapsedTimeMs", 0L)
            
            isRunning = isRunningParam
            elapsedTimeMs = elapsedParam
            startTimeMs = System.currentTimeMillis() - elapsedParam
            
            updateNotification()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        unregisterActionsReceiver()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Stopwatch Active Tracker",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Persistent notification tracking active stopwatch session."
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun registerActionsReceiver() {
        val filter = IntentFilter().apply {
            addAction(ACTION_PLAY_PAUSE)
            addAction(ACTION_LAP)
        }
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    ACTION_PLAY_PAUSE -> handlePlayPause()
                    ACTION_LAP -> handleLap()
                }
            }
        }
        registerReceiver(receiver, filter)
    }

    private fun unregisterActionsReceiver() {
        receiver?.let {
            unregisterReceiver(it)
            receiver = null
        }
    }

    private fun handlePlayPause() {
        if (isRunning) {
            // Pause
            elapsedTimeMs = System.currentTimeMillis() - startTimeMs
            isRunning = false
        } else {
            // Start/Resume
            startTimeMs = System.currentTimeMillis() - elapsedTimeMs
            isRunning = true
        }

        saveStateToPreferences()
        updateNotification()
        
        // Notify Flutter
        mainActivityInstance?.runOnUiThread {
            mainActivityInstance?.notifyStopwatchAction("toggle")
        }
    }

    private fun handleLap() {
        val currentTotalMs = if (isRunning) {
            System.currentTimeMillis() - startTimeMs
        } else {
            elapsedTimeMs
        }

        val sharedPref = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val lapsJsonStr = sharedPref.getString("flutter.stopwatch_laps", null)
        val lapsArray = if (lapsJsonStr != null) {
            try {
                JSONArray(lapsJsonStr)
            } catch (e: Exception) {
                JSONArray()
            }
        } else {
            JSONArray()
        }

        val newIndex = lapsArray.length() + 1
        val lastCumulativeMs = if (lapsArray.length() > 0) {
            try {
                val lastObject = lapsArray.getJSONObject(lapsArray.length() - 1)
                lastObject.getLong("cumulativeTimeMs")
            } catch (e: Exception) {
                0L
            }
        } else {
            0L
        }

        val lapTimeMs = currentTotalMs - lastCumulativeMs

        val newLapJson = JSONObject().apply {
            put("index", newIndex)
            put("lapTimeMs", lapTimeMs)
            put("cumulativeTimeMs", currentTotalMs)
        }
        lapsArray.put(newLapJson)

        sharedPref.edit().apply {
            putString("flutter.stopwatch_laps", lapsArray.toString())
            apply()
        }

        // Notify Flutter
        mainActivityInstance?.runOnUiThread {
            mainActivityInstance?.notifyStopwatchAction("lap")
        }
    }

    private fun saveStateToPreferences() {
        val sharedPref = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val stateJson = JSONObject().apply {
            put("elapsedTimeMs", elapsedTimeMs)
            put("isRunning", isRunning)
            if (isRunning) {
                val df = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", java.util.Locale.US)
                df.timeZone = java.util.TimeZone.getTimeZone("UTC")
                val isoDateStr = df.format(java.util.Date(startTimeMs)) + "Z"
                put("startTimeIso", isoDateStr)
            } else {
                put("startTimeIso", null)
            }
        }

        sharedPref.edit().apply {
            putString("flutter.stopwatch_state", stateJson.toString())
            apply()
        }
    }

    private fun updateNotification() {
        val playPauseText = if (isRunning) "Pause" else "Resume"
        val playPauseIcon = if (isRunning) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play

        val playPauseIntent = Intent(ACTION_PLAY_PAUSE)
        val playPausePending = PendingIntent.getBroadcast(
            this,
            1,
            playPauseIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )

        val lapIntent = Intent(ACTION_LAP)
        val lapPending = PendingIntent.getBroadcast(
            this,
            2,
            lapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )

        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val openAppPending = PendingIntent.getActivity(
            this,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Aizen Stopwatch")
            .setContentText(if (isRunning) "Running" else "Paused")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(openAppPending)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .addAction(playPauseIcon, playPauseText, playPausePending)
            .addAction(android.R.drawable.ic_input_add, "Lap", lapPending)

        if (isRunning) {
            builder.setUsesChronometer(true)
            val elapsedMs = System.currentTimeMillis() - startTimeMs
            builder.setWhen(System.currentTimeMillis() - elapsedMs)
        } else {
            builder.setUsesChronometer(false)
            val hours = elapsedTimeMs / 3600000
            val minutes = (elapsedTimeMs % 3600000) / 60000
            val seconds = (elapsedTimeMs % 60000) / 1000
            val timeStr = String.format("%02d:%02d:%02d", hours, minutes, seconds)
            builder.setContentText("Paused: $timeStr")
        }

        startForeground(NOTIFICATION_ID, builder.build())
    }
}
