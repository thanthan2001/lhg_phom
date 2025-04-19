package com.example.lhg_phom

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "rfid_channel"
    private var rfidHandler: RFIDHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        rfidHandler = RFIDHandler(this, methodChannel)

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "connectRFID" -> result.success(rfidHandler?.connect())
                "startScan" -> {
                    rfidHandler?.startScan()
                    result.success(true)
                }
                "stopScan" -> {
                    rfidHandler?.stopScan()
                    result.success(true)
                }
                "disconnectRFID" -> {
                    rfidHandler?.disconnect()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
