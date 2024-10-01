package com.hao.device_app.service

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.ByteBuffer

class MyVpnService : VpnService() {
    private val TAG = "MyVpnService"
    private var vpnThread: Thread? = null
    private var vpnInterface: ParcelFileDescriptor? = null

    // khởi tạo vpn
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Starting VPN service")

        if (vpnThread != null) return START_STICKY
        vpnThread = Thread {
            try {
                val builder = Builder()
                builder.setSession("My VPN Session")
                    .addAddress("10.0.2.2", 24)
                    .addDnsServer("8.8.8.8")
                    .addRoute("0.0.0.0", 0)
                vpnInterface = builder.establish()
                Log.d(TAG, "VPN interface established")

                if (vpnInterface != null) {
                    val inputStream = FileInputStream(vpnInterface!!.fileDescriptor)
                    val outputStream = FileOutputStream(vpnInterface!!.fileDescriptor)

                    val packet = ByteBuffer.allocate(1500)
                    while (true) {
                        val length = inputStream.read(packet.array())
                        if (length > 0) {
                            if (isYoutubePacket(packet)) {
                                Log.d(TAG, "Youtube packet received")
                                continue
                            }
                            outputStream.write(packet.array(), 0, length)
                        }
                    }

                }
            } catch (e: Exception) {
                Log.e(TAG, "Error establishing VPN connection", e)
            }
        }
        vpnThread!!.start()
        return START_STICKY
    }


    // kết thúc vpn
    override fun onDestroy() {
        super.onDestroy()
        vpnThread?.interrupt()
        vpnThread = null
        try {
            vpnInterface?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Error closing VPN interface", e)
        }
    }

    private fun isYoutubePacket(packet: ByteBuffer): Boolean {
        Log.d(TAG, "Checking if packet is a Youtube packet")
        val data = String(packet.array())
        return data.contains("tratu.soha")
    }
}