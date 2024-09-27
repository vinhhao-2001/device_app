package com.hao.device_app

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.os.Build
import android.os.BatteryManager
import android.media.AudioManager
import android.provider.Settings

class DeviceInfoChannel(private val context: Context){
    private val deviceInfoChannel = "device_info_channel"
    private  lateinit var methodChannel: MethodChannel

    fun configureChannel(flutterEngine: FlutterEngine){
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceInfoChannel)
        methodChannel.setMethodCallHandler{call, result ->
            if(call.method == "getDeviceInfo"){
                val deviceInfo = getDeviceInfo()
                result.success(deviceInfo)
            }else{
                result.notImplemented()
            }
        }
    }
    private fun  getDeviceInfo(): Map<String, Any>{
        val deviceInfo = hashMapOf<String, Any>()
        deviceInfo["deviceName"] = Build.MODEL
        deviceInfo["deviceVersion"] = Build.VERSION.RELEASE

        val batteryManage = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val batteryLevel = batteryManage.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        deviceInfo["batteryLevel"] = batteryLevel.toString()

        val screenBrightness = Settings.System.getInt(context.contentResolver, Settings.System.SCREEN_BRIGHTNESS, 0)
        deviceInfo["screenBrightness"] = screenBrightness.toString()

        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val volume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        deviceInfo["volume"] = volume.toString()

        return deviceInfo
    }
}