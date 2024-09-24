package com.example.device_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.content.Intent


class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // xin các quyền để kiểm soát thiết bị
        val requestPermissions = RequestPermissions(this)
        requestPermissions.configureChannel(flutterEngine)
        // Thời gian sử dụng ứng dụng
        val appUsageChannel = AppUsageChannel(this)
        appUsageChannel.configureChannel(flutterEngine)

        // lắng nghe ứng dụng cài đặt hoặc gỡ bỏ
        val appInstalledChannel = AppInstalledChannel(this)
        appInstalledChannel.configureChannel(flutterEngine)

        // Gửi thông báo ứng dụng cài đặt
       val serviceIntent = Intent(this, AppEventService::class.java)
       startService(serviceIntent)

        // Lấy thông tin thiết bị
        val deviceInfoChannel = DeviceInfoChannel(this)
        deviceInfoChannel.configureChannel(flutterEngine)

        // giới hạn ứng dụng
        val blockAppChannel = BlockAppChannel(this)
        blockAppChannel.configureChannel(flutterEngine)
    }
}