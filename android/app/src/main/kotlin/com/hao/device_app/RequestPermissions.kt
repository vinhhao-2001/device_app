package com.hao.device_app

import android.Manifest
import android.app.Activity
import android.app.AppOpsManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class RequestPermissions(private val context: Context) {
    private val channel = "request_permissions_channel"
    private lateinit var methodChannel: MethodChannel

    fun configureChannel(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "adminPermission" -> result.success(requestAdminPermission())
                "usageStatsPermission" -> result.success(requestUsageStatsPermissions())
                "overlayPermission" -> result.success(requestOverlayPermission())
                "accessibilityPermission" -> result.success(requestAccessibilityPermission())
                "locationPermission" -> result.success(requestLocationPermission())
                else -> result.notImplemented()
            }
        }
    }

    // truy cập vào trợ năng
    private fun requestAccessibilityPermission(): Boolean {
        // Check if the accessibility service is enabled
        val componentName = ComponentName(context, MyAccessibilityService::class.java)
        val enabledServicesSetting = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: ""
        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)

        while (colonSplitter.hasNext()) {
            val enabledService = colonSplitter.next()
            if (enabledService.equals(componentName.flattenToString(), ignoreCase = true)) {
                return true
            }
        }
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        return false
    }


    // xin quyền truy cập vị trí
    private fun requestLocationPermission(): Boolean {
        return if (ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                context as Activity,
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                REQUEST_CODE_LOCATION // requestCode
            )
            false
        } else {
            true
        }
    }

    // xin quyền hiển thị lên màn hình
    private fun requestOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(context)) {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:" + context.packageName)
                )
                (context as Activity).startActivityForResult(
                    intent,
                    REQUEST_CODE_OVERLAY_PERMISSION
                )
                false
            } else {
                true
            }
        } else {
            true
        }
    }

    // xin quyền truy cập thông tin sử dụng
    private fun requestUsageStatsPermissions(): Boolean {
        val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )

        return if (mode != AppOpsManager.MODE_ALLOWED) {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            context.startActivity(intent)
            false
        } else {
            true
        }
    }

    // xin quyền cài đặt thiết bị
    private fun requestAdminPermission(): Boolean {
        val devicePolicyManager =
            context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val componentName = ComponentName(context, MyDeviceAdminReceiver::class.java)

        return if (!devicePolicyManager.isAdminActive(componentName)) {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
            intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
            intent.putExtra(
                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "Device Admin Permission required for this app."
            )

            (context as Activity).startActivityForResult(intent, REQUEST_CODE_DEVICE_ADMIN)
            false
        } else {
            true
        }
    }

    companion object {
        const val REQUEST_CODE_OVERLAY_PERMISSION = 1
        const val REQUEST_CODE_DEVICE_ADMIN = 2
        const val REQUEST_CODE_LOCATION = 3
    }
}