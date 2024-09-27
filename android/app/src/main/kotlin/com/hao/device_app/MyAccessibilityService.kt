package com.hao.device_app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

class MyAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Xử lý khi có cửa sổ thay đổi
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            // lấy tên gói ứng dụng
            val packageName = event.packageName?.toString()
            // Xử lý thông tin cửa sổ
            println("Window state changed: $packageName")
        }
    }

    override fun onInterrupt() {
        // Xử lý khi dịch vụ bị ngắt
    }

    override fun onServiceConnected() {
        // xử lý khi dịch vụ được kết nối

    }

}