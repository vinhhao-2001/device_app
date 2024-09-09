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
        // Thời gian sử dụng ứng dụng
        val appUsageChannel = AppUsageChannel(this)
        appUsageChannel.configureChannel(flutterEngine)

        // lắng nghe ứng dụng cài đặt hoặc gỡ bỏ
        val appInstalledChannel = AppInstalledChannel(this)
        appInstalledChannel.configureChannel(flutterEngine)

        // Lấy thông tin thiết bị
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREEN_TIME_CHANNEL
        ).setMethodCallHandler { call, result ->
        }
    }

}