package  com.hao.device_app

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import android.content.pm.PackageManager
import android.app.admin.DevicePolicyManager

class BlockAppChannel (private val context: Context){
    private val APP_LIMIT_CHANNEL = "app_limit_channel"
    private lateinit var methodChannel : MethodChannel

    fun configureChannel(flutterEngine: FlutterEngine){
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_LIMIT_CHANNEL)
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
        requestDeviceAdmin()
    }
    private  fun requestDeviceAdmin(){
        if ()
        val devicePolicyManager = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val adminComponentName = devicePolicyManager.adminComponentName
        val intent = devicePolicyManager.createDeviceManagementEnableIntentFilter()
        context.startActivityForResult(intent, REQUEST_CODE_ENABLE_ADMIN)
    }
    companion object {
        private const val REQUEST_CODE_ENABLE_ADMIN = 1
    }
}