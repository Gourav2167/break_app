package com.haveabreak.have_a_break

import java.util.Calendar

import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.util.Log
import android.app.AppOpsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Process
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.haveabreak/usage"
    private var methodChannel: MethodChannel? = null

    private val usageReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val pkg = intent?.getStringExtra("packageName")
            val sess = intent?.getLongExtra("sessionDuration", 0) ?: 0
            
            Log.d("MainActivity", "Real-time update: $pkg (+${sess}s)")
            
            runOnUiThread {
                methodChannel?.invokeMethod("onUsageData", mapOf(
                    "packageName" to pkg,
                    "sessionDuration" to sess
                ))
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    startUsageService()
                    result.success(true)
                }
                "stopService" -> {
                    stopUsageService()
                    result.success(true)
                }
                "checkPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestPermission" -> {
                    requestUsageStatsPermission()
                    result.success(true)
                }
                "getUsageStats" -> {
                    result.success(getAllAppsUsage())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getAllAppsUsage(): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        // Use queryUsageStats and aggregate manually for better reliability
        val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
        
        Log.d("MainActivity", "Usage data found: ${stats?.size ?: 0} entries")
        if (stats == null || stats.isEmpty()) {
            val hasPerm = hasUsageStatsPermission()
            Log.w("MainActivity", "No stats found! Permission granted: $hasPerm")
        }

        val aggregatedStats = stats?.groupBy { it.packageName }?.mapValues { entry ->
            entry.value.sumOf { it.totalTimeInForeground }
        } ?: emptyMap()
        
        val packageManager = packageManager
        val installedApps = packageManager.getInstalledApplications(0)
        val result = mutableListOf<Map<String, Any>>()

        for (appInfo in installedApps) {
            val packageName = appInfo.packageName
            val appName = packageManager.getApplicationLabel(appInfo).toString()
            val totalTime = aggregatedStats[packageName]?.div(1000) ?: 0
            
            result.add(mapOf(
                "packageName" to packageName,
                "appName" to appName,
                "duration" to totalTime
            ))
        }
        return result.sortedByDescending { (it["duration"] as? Long) ?: 0L }
    }

    override fun onStart() {
        super.onStart()
        val filter = IntentFilter("com.haveabreak.USAGE_DATA")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(usageReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(usageReceiver, filter)
        }
    }

    override fun onStop() {
        super.onStop()
        unregisterReceiver(usageReceiver)
    }

    private fun startUsageService() {
        val intent = Intent(this, UsageService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopUsageService() {
        val intent = Intent(this, UsageService::class.java)
        stopService(intent)
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        }
        val granted = mode == AppOpsManager.MODE_ALLOWED
        Log.d("MainActivity", "Permission check: $granted (mode: $mode)")
        return granted
    }

    private fun requestUsageStatsPermission() {
        if (!hasUsageStatsPermission()) {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            startActivity(intent)
        }
    }
}
