package com.hao.device_app.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.IBinder
import android.util.Log
import com.hao.device_app.UsageInfoHandler
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AppEventService : Service() {
    private lateinit var methodChannel: MethodChannel
    private val channelID = "app_installed_channel_id"

    private val appInstalledReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.action
            val packageName = intent?.data?.schemeSpecificPart
            if (packageName != null && context != null) {
                when (action) {
                    Intent.ACTION_PACKAGE_ADDED -> {
                        val appName = context.packageManager.getApplicationLabel(
                            context.packageManager.getApplicationInfo(packageName, 0)
                        ).toString()
                        val appIcon = context.packageManager.getApplicationIcon(
                            context.packageManager.getApplicationInfo(packageName, 0)
                        )
                        sendAppInstalledEvent("cài đặt", packageName, appName, appIcon)
                    }
                    Intent.ACTION_PACKAGE_REMOVED -> {
                        sendAppInstalledEvent("gỡ bỏ", packageName)
                    }
                }
            }
        }
    }

    // Khởi tạo và đăng ký BroadcastReceiver
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val flutterEngine = FlutterEngine(this)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app_installed_channel")

        // Đăng ký BroadcastReceiver
        val filter = IntentFilter()
        filter.addAction(Intent.ACTION_PACKAGE_ADDED)
        filter.addAction(Intent.ACTION_PACKAGE_REMOVED)
        filter.addDataScheme("package")
        registerReceiver(appInstalledReceiver, filter)
    }

    // Tạo kênh thông báo
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "App Installed Notifications"
            val descriptionText = "Notifications for app installations and removals"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(channelID, name, importance).apply {
                description = descriptionText
            }
            val notificationManager: NotificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    // Gửi ứng dụng cài đặt hoặc gỡ bỏ ứng dụng
    private fun sendAppInstalledEvent(
        eventType: String,
        packageName: String,
        appName: String? = null,
        appIcon: Drawable? = null
    ) {
        val event = mutableMapOf<String, Any>(
            "event" to eventType,
            "packageName" to packageName,
        )
        appName?.let { event["appName"] = it }
        appIcon?.let { event["appIcon"] = UsageInfoHandler(this).drawableToByteArray(it) }

        // Gọi phương thức invokeMethod
        if (::methodChannel.isInitialized) {
            methodChannel.invokeMethod("appInstalled", event)
        } else {
            Log.e("AppInstallService", "MethodChannel is not initialized")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(appInstalledReceiver)
    }
}
