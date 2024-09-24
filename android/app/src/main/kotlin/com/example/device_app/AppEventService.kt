package com.example.device_app

import android.app.Notification
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

        // Gửi thông báo
        showNotification(eventType, packageName, appName)

        // Gọi phương thức invokeMethod
        if (::methodChannel.isInitialized) {
            methodChannel.invokeMethod("appInstalled", event)
        } else {
            Log.e("AppInstallService", "MethodChannel is not initialized")
        }
    }

    private fun showNotification(eventType: String, packageName: String, appName: String?) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val contentTitle = when (eventType) {
            "cài đặt" -> "Ứng dụng được cài đặt"
            "gỡ bỏ" -> "Ứng dụng bị gỡ bỏ"
            else -> "Thông báo ứng dụng"
        }

        val contentText = "$contentTitle: ${appName ?: packageName}"

        val notificationBuilder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelID)
                .setSmallIcon(android.R.drawable.ic_dialog_info) // Bạn có thể thay đổi biểu tượng
                .setContentTitle(contentTitle)
                .setContentText(contentText)
                .setPriority(Notification.PRIORITY_DEFAULT)
                .setAutoCancel(true)
        } else {
            Notification.Builder(this)
                .setSmallIcon(android.R.drawable.ic_dialog_info) // Bạn có thể thay đổi biểu tượng
                .setContentTitle(contentTitle)
                .setContentText(contentText)
        }

        notificationManager.notify(System.currentTimeMillis().toInt(), notificationBuilder.build())
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
