package com.hao.device_app.channel

import android.content.Context
import android.content.Intent
import com.hao.device_app.service.MyVpnService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class VpnChannel(private val context: Context) {
    private val vpnChannel = "vpn_channel"
    private lateinit var methodChannel: MethodChannel

    fun configureChannel(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, vpnChannel)
        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "startVpn") {
                startVpnService()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startVpnService() {
        val intent = Intent(context, MyVpnService::class.java)
        context.startService(intent)
    }
}