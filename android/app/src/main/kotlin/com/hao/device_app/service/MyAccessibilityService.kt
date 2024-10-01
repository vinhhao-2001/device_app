package com.hao.device_app.service

import android.accessibilityservice.AccessibilityService
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import com.hao.device_app.overlay.BlockOverlay
import com.hao.device_app.overlay.RemoveMyAppOverlay

class MyAccessibilityService : AccessibilityService() {

    companion object {
        const val LAUNCHER_PACKAGE = "com.google.android.apps.nexuslauncher"
        const val DEVICE_APP_NAME = "Device App"
        const val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"
        const val BLOCKED_APPS_KEY = "flutter.listBlockedApps"
        const val BLOCKED_WEBSITES_KEY = "flutter.listBlockedWebsites"
        const val TAG = "MyAccessibilityService"
    }

    private var prevApp: String = ""
    private var prevUrl: String = ""

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            val packageName = it.packageName?.toString() ?: return

            when (it.eventType) {
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
                AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                    handleWebViewEvent(it)
                }

                else -> {
                    if (packageName == LAUNCHER_PACKAGE) {
                        handleLauncherEvent(it)
                    }
                }
            }
        }
    }


    private fun handleLauncherEvent(event: AccessibilityEvent) {
        val contentDescription = event.contentDescription?.toString() ?: return
        // Xử lý sự kiện khi người muốn xoá ứng dụng Device App
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_LONG_CLICKED) {
            if (contentDescription.contains(DEVICE_APP_NAME)) {
                showRemoveMyAppOverlay()
            }
        }
        // Xử lý sự kiện khi người dùng vào ứng dụng
        if (isAppBlocked(contentDescription)) {
            showBlockScreen()
        }
    }

    // Xử lý sự kiện khi URL được tải lên
    private fun handleWebViewEvent(event: AccessibilityEvent) {
        val parentNodeInfo: AccessibilityNodeInfo = event.source ?: return
        val packageName: String = event.packageName?.toString() ?: return
        val browserConfig: SupportedBrowserConfig = getBrowserConfig(packageName) ?: return

        val capturedUrl: String? = captureUrl(parentNodeInfo, browserConfig)
        parentNodeInfo.recycle()

        if (!capturedUrl.isNullOrEmpty() && (packageName != prevApp || capturedUrl != prevUrl)) {
            prevApp = packageName
            prevUrl = capturedUrl
            handleUrlBlocking(capturedUrl)
        }
    }

    // Kiểm tra xem ứng dụng có bị chặn không
    private fun isAppBlocked(appName: String): Boolean {
        val blockedApps = getBlockedApps()
        return blockedApps.contains(appName)
    }

    // Hiển thị overlay để khi muốn xoá ứng dụng Device App
    private fun showRemoveMyAppOverlay() {
        RemoveMyAppOverlay(this).showRemoveMyAppOverlay()
    }

    // Hiển thị màn hình chặn
    private fun showBlockScreen() {
        BlockOverlay(this).showBlockScreen()
    }

    // Lấy danh sách ứng dụng bị chặn từ shared preferences
    private fun getBlockedApps(): List<String> {
        val sharedPreferences = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        val blockedApps = sharedPreferences.getString(BLOCKED_APPS_KEY, "")
        return blockedApps?.split("+") ?: emptyList()
    }

    // Lấy danh sách website bị chặn từ shared preferences
    private fun getBlockedWebsites(): List<String> {
        val sharedPreferences = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        val blockedWebsites = sharedPreferences.getString(BLOCKED_WEBSITES_KEY, "")
        return blockedWebsites?.split("+") ?: emptyList()
    }

    // Kiểm tra xem URL có bị chặn không
    private fun handleUrlBlocking(capturedUrl: String) {
        val blockedWebsites = getBlockedWebsites()
        if (blockedWebsites.any { capturedUrl.contains(it, ignoreCase = true) }) {
            redirectToBlankPage()
        }
    }

    // Chuyển hướng đến trang trắng
    private fun redirectToBlankPage() {
        Log.d(TAG, "Redirecting to blank page")
        val blankPage: Uri = Uri.parse("about:blank")
        val intent = Intent(Intent.ACTION_VIEW, blankPage).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        applicationContext.startActivity(intent)
    }

    // Lấy cấu hình cho trình duyệt dựa trên tên gói ứng dụng
    private fun getBrowserConfig(packageName: String): SupportedBrowserConfig? {
        return SupportedBrowserConfig.get().find { it.packageName == packageName }
    }

    // Lấy URL từ nút tìm kiếm
    private fun captureUrl(info: AccessibilityNodeInfo, config: SupportedBrowserConfig): String? {
        return info.findAccessibilityNodeInfosByViewId(config.addressBarId)
            .firstOrNull()?.text?.toString()
    }

    // Xóa lịch sử ứng dụng trong đa nhiệm
    private fun clearRecentApps(context: Context, packageName: String) {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // Xử lý khi API >= 24
            activityManager.appTasks.forEach { appTask ->
                if (appTask.taskInfo.baseActivity?.packageName == packageName) {
                    appTask.finishAndRemoveTask()
                }
            }
        }
    }

    override fun onInterrupt() {
        // Handle service interruption
    }

    override fun onServiceConnected() {
        // Handle service connection
    }

    class SupportedBrowserConfig(val packageName: String, val addressBarId: String) {
        companion object SupportedBrowsers {
            fun get(): List<SupportedBrowserConfig> {
                return listOf(
                    SupportedBrowserConfig("com.android.chrome", "com.android.chrome:id/url_bar"),
                    SupportedBrowserConfig(
                        "org.mozilla.firefox",
                        "org.mozilla.firefox:id/mozac_browser_toolbar_url_view"
                    ),
                    SupportedBrowserConfig("com.opera.browser", "com.opera.browser:id/url_field"),
                    SupportedBrowserConfig(
                        "com.opera.mini.native",
                        "com.opera.mini.native:id/url_field"
                    ),
                    SupportedBrowserConfig(
                        "com.duckduckgo.mobile.android",
                        "com.duckduckgo.mobile.android:id/omnibarTextInput"
                    ),
                    SupportedBrowserConfig("com.microsoft.emmx",
                        "com.microsoft.emmx:id/url_bar"),)
            }
        }
    }
}
