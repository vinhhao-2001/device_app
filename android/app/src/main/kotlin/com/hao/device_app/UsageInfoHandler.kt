package com.hao.device_app

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.AdaptiveIconDrawable
import android.provider.Settings
import java.io.ByteArrayOutputStream
import java.util.Calendar
import android.content.pm.PackageManager
import android.os.Build

class UsageInfoHandler(private val context: Context) {

    fun getAppUsageInfo(): List<Map<String, Any>> {
        // Logic lấy thông tin thời gian sử dụng ứng dụng
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, -1)
        val endTime = System.currentTimeMillis()
        val startTime = calendar.timeInMillis

        val usageStatsManager =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            } else {
                return emptyList()
            }
        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        ) ?: emptyList()

        val installedApps = getInstalledApps()
        val appUsageInfoList = mutableListOf<Map<String, Any>>()
        val usageMap = mutableMapOf<String, Long>()

        for (usageStats in usageStatsList) {
            usageMap[usageStats.packageName] = usageStats.totalTimeInForeground
        }

        for (app in installedApps) {
            val packageName = app["packageName"] as String
            val usageTime = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                usageMap.getOrDefault(packageName, 0L)
            } else {
                usageMap[packageName] ?: 0L
            }
            appUsageInfoList.add(app + mapOf("usageTime" to usageTime))
        }

        return appUsageInfoList
    }
    // Kiểm tra quyền truy cập thông tin sử dụng
    fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
    // Yêu cầu quyền truy cập thông tin sử dụng
    fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        context.startActivity(intent)
    }
    // Lấy danh sách ứng dụng đã cài đặt
    private fun getInstalledApps(): List<Map<String, Any>> {
        // Logic lấy danh sách ứng dụng đã cài đặt
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val apps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
        } else {
            context.packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
        }
        return apps.map { info ->
            val appInfo = info.activityInfo.applicationInfo
            val appName = context.packageManager.getApplicationLabel(appInfo).toString()
            val packageName = appInfo.packageName
            val appIcon = context.packageManager.getApplicationIcon(appInfo)

            mapOf(
                "name" to appName,
                "packageName" to packageName,
                "icon" to drawableToByteArray(appIcon)
            )
        }
    }
    // Chuyển đổi Drawable thành ByteArray
     fun drawableToByteArray(drawable: Drawable): ByteArray {
        val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                is AdaptiveIconDrawable -> {
                    val width = drawable.intrinsicWidth
                    val height = drawable.intrinsicHeight
                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    val canvas = android.graphics.Canvas(bitmap)
                    drawable.setBounds(0, 0, width, height)
                    drawable.draw(canvas)
                    bitmap
                }
                else -> return byteArrayOf()
            }
        } else {
            when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                else -> {
                    val width = drawable.intrinsicWidth
                    val height = drawable.intrinsicHeight
                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    val canvas = android.graphics.Canvas(bitmap)
                    drawable.setBounds(0, 0, width, height)
                    drawable.draw(canvas)
                    bitmap
                }
            }
        }

        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }
}
