package com.hao.device_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import android.graphics.drawable.Drawable


class MainActivity : FlutterActivity() {
    private val APP_INSTASLLED_CHANNEL = "app_installed_channel"
    private val SCREEN_TIME_CHANNEL = "screen_time"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val appUsageChannel = AppUsageChannel(this)
        appUsageChannel.configureChannel(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREEN_TIME_CHANNEL
        ).setMethodCallHandler { call, result ->
        }

        val filter = IntentFilter()
        filter.addAction(Intent.ACTION_PACKAGE_ADDED)
        filter.addAction(Intent.ACTION_PACKAGE_REMOVED)
        filter.addDataScheme("package")
        registerReceiver(appInstalledReceiver, filter)
    }

    private val appInstalledReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.action
            val packageName = intent?.data?.schemeSpecificPart
            if (packageName != null && context != null) {
                when (action) {
                    Intent.ACTION_PACKAGE_ADDED -> {
                        // Xử lý khi ứng dụng được cài đặt
                        val appName = context?.packageManager?.getApplicationLabel(
                            context.packageManager.getApplicationInfo(packageName, 0)
                        ).toString()
                        val appIcon = context?.packageManager?.getApplicationIcon(
                            context.packageManager.getApplicationInfo(packageName, 0)
                        )
                        // Drawable icon = UsageInfoHandler(context).drawableToByteArray(appIcon!!)
                        sendAppInstalledEvent("install", packageName, appName, appIcon)
                        Log.d("MainActivity", "App installed: $appIcon")
                    }

                    Intent.ACTION_PACKAGE_REMOVED -> {
                        // Xử lý khi ứng dụng bị xóa
                        val appName = packageName
                        sendAppInstalledEvent("remove", packageName)
                    }
                }
            }
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
        MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            APP_INSTASLLED_CHANNEL
        ).invokeMethod("appInstalled", event)
    }
}
