package com.haveabreak.have_a_break

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import android.app.usage.UsageStatsManager

class UsageService : Service() {
    private val NOTIFICATION_ID = 1
    private val CHANNEL_ID = "UsageTrackingChannel"
    private lateinit var db: UsageDatabase
    private var isRunning = false
    private val handler = Handler(Looper.getMainLooper())
    private var lastPackage: String? = null
    private var sessionStartTime: Long = 0
    private var runnable: Runnable? = null

    override fun onCreate() {
        super.onCreate()
        db = UsageDatabase(this)
        Log.d("UsageService", "Service created with DB")
    }

    private fun startTracking() {
        runnable = object : Runnable {
            override fun run() {
                if (!isRunning) return

                val currentPkg = getActivePackage()
                val now = System.currentTimeMillis()

                if (currentPkg != null) {
                    // Update DB every second for the active app
                    db.logUsage(currentPkg, 1)

                    if (currentPkg != lastPackage) {
                        Log.d("UsageService", "App Changed: $currentPkg")
                        lastPackage = currentPkg
                        sessionStartTime = now
                    }

                    val duration = (now - sessionStartTime) / 1000
                    
                    val intent = Intent("com.haveabreak.USAGE_DATA")
                    intent.setPackage(packageName)
                    intent.putExtra("packageName", currentPkg)
                    intent.putExtra("sessionDuration", duration)
                    sendBroadcast(intent)

                    if (duration % 10 == 0L) {
                        Log.d("UsageService", "Active: $currentPkg (${duration}s saved to DB)")
                    }
                }

                handler.postDelayed(this, 1000)
            }
        }
        handler.post(runnable!!)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("UsageService", "Service onStartCommand")
        if (!isRunning) {
            isRunning = true
            startForeground(NOTIFICATION_ID, createNotification())
            startTracking()
        }
        return START_STICKY
    }

    override fun onDestroy() {
        Log.d("UsageService", "Service destroying")
        isRunning = false
        runnable?.let { handler.removeCallbacks(it) }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun getActivePackage(): String? {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        // 60s window to find the most recent app
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, now - 1000 * 60, now)
        
        if (stats == null || stats.isEmpty()) return null
        
        return stats.maxByOrNull { it.lastTimeUsed }?.packageName
    }

    private fun createNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Real-time Usage Tracker",
                NotificationManager.IMPORTANCE_LOW
            )
            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Have A Break is Active")
            .setContentText("Monitoring your app usage sessions...")
            .setSmallIcon(android.R.drawable.ic_menu_myplaces)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
}
