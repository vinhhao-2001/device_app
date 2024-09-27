package com.hao.device_app

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent

class MyDeviceAdminReceiver: DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        // Xử lý khi thiết bị được cài đặt thành công
    }
    override fun onDisabled(context: Context, intent: Intent) {
        // Xử lý khi thiết bị bị tắt
    }
}