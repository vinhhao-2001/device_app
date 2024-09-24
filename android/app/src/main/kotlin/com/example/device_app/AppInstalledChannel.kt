package com.example.device_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.drawable.Drawable
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AppInstalledChannel(private val context: Context) {
    private val appInstalledChannel = "app_installed_channel"
    private lateinit var methodChannel: MethodChannel

    fun configureChannel(flutterEngine: FlutterEngine) {
        methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appInstalledChannel)

        val filter = IntentFilter()
        filter.addAction(Intent.ACTION_PACKAGE_ADDED)
        filter.addAction(Intent.ACTION_PACKAGE_REMOVED)
        filter.addDataScheme("package")
        context.registerReceiver(appInstalledReceiver, filter)
    }

    private val appInstalledReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.action
            val packageName = intent?.data?.schemeSpecificPart
            if (packageName != null && context != null) {
                when (action) {
                    Intent.ACTION_PACKAGE_ADDED -> {
                        // Handle app installed
                        val appName = context.packageManager.getApplicationLabel(
                            context.packageManager.getApplicationInfo(packageName, 0)
                        ).toString()
                        val appIcon = context.packageManager.getApplicationIcon(
                            context.packageManager.getApplicationInfo(packageName, 0))
                        sendAppInstalledEvent("cài đặt", packageName, appName, appIcon)
                        Log.d("AppInstalledChannel", "App installed: $appIcon")
                    }

                    Intent.ACTION_PACKAGE_REMOVED -> {
                        // Handle app removed
                        sendAppInstalledEvent("gỡ bỏ", packageName)
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
        appIcon?.let { event["appIcon"] = UsageInfoHandler(context).drawableToByteArray(it) }
        methodChannel.invokeMethod("appInstalled", event)
    }
}
