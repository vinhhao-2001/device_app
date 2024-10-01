package com.hao.device_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.content.Intent
import com.hao.device_app.channel.AppInstalledChannel
import com.hao.device_app.channel.AppUsageChannel
import com.hao.device_app.channel.BlockAppChannel
import com.hao.device_app.channel.DeviceInfoChannel
import com.hao.device_app.channel.VpnChannel
import com.hao.device_app.service.AppEventService


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

        // khởi động vpn
        val vpnChannel = VpnChannel(this)
        vpnChannel.configureChannel(flutterEngine)
    }
}