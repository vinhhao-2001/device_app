package com.hao.device_app.channel

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.util.Log
import com.hao.device_app.UsageInfoHandler

class AppUsageChannel(private val context: Context) {
    private val appUsageChannel = "app_usage_channel"

    fun configureChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appUsageChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "getAppUsageInfo") {
                    val usageInfoHandler = UsageInfoHandler(context)
                    if (usageInfoHandler.hasUsageStatsPermission()) {
                        val appUsageInfo = usageInfoHandler.getAppUsageInfo()
                        Log.d("AppUsageInfo", appUsageInfo.toString())
                        result.success(appUsageInfo)
                    } else {
                        usageInfoHandler.requestUsageStatsPermission()
                        result.error("PERMISSION_DENIED", "Usage access permission denied", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
