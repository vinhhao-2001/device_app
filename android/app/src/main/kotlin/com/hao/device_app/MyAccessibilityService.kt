package com.hao.device_app

import android.accessibilityservice.AccessibilityService
import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.view.accessibility.AccessibilityEvent

class MyAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Xử lý khi có cửa sổ thay đổi
        event?.let {
            if (it.eventType == AccessibilityEvent.TYPE_VIEW_LONG_CLICKED) {
                val packageName = it.packageName.toString()

                println("packageName: $packageName")
                if (isAppBlocked("com.android.chrome")) {
                    showBlockScreen()
                }
            }

            val packageName = it.packageName.toString()
            // Kiểm tra nếu packageName là của launcher
            if (packageName == "com.google.android.apps.nexuslauncher") {
                val contentDescription = it.contentDescription?.toString()
                println("Chạm vào ứng dụng: $contentDescription")

                // Kiểm tra nếu ứng dụng bị chặn
                if (contentDescription != null && isAppBlocked(contentDescription)) {
                    showBlockScreen()
                }
            }
        }
    }

    // kiểm tra xem ứng dụng có nằm trong danh sách bị chặn hay không
    private fun isAppBlocked(packageName: String): Boolean {
        val blockedApps = listOf("Chrome", "Cài đặt")
        return blockedApps.contains(packageName)
    }
    // xoá ứng dụng khỏi danh sách ứng dụng gần đây
    private fun clearRecentApps(context: Context, packageName: String) {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            activityManager.appTasks.forEach { appTask ->
                if (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        appTask.taskInfo.baseActivity!!.packageName == packageName
                    } else {
                        TODO("VERSION.SDK_INT < M")
                    }
                ) {
                    appTask.finishAndRemoveTask()
                }
            }
    }


    // hiển thị giao diện chặn ứng dụng
    private fun showBlockScreen() {

        val blockOverlay = BlockOverlay(this)
        blockOverlay.showBlockScreen()
    }


    override fun onInterrupt() {
        // Xử lý khi dịch vụ bị ngắt
    }

    override fun onServiceConnected() {
        // xử lý khi dịch vụ được kết nối
    }
}