package com.hao.device_app.channel

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import android.content.pm.PackageManager

class BlockAppChannel (private val context: Context){
    private val appLimitChannel = "app_limit_channel"
    private lateinit var methodChannel : MethodChannel

    fun configureChannel(flutterEngine: FlutterEngine){
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appLimitChannel)
        methodChannel.setMethodCallHandler{call, result ->
            if(call.method == "appLimit"){
                blockApp()
                result.success(null)
            }else{
                result.notImplemented()
            }
        }
    }
    private fun blockApp(){
        val permissons = context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_PERMISSIONS).requestedPermissions
        Log.d("permissons", permissons?.toList().toString())
    }
}