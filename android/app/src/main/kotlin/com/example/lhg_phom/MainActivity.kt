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

                "scanRFID" -> {
                    val mode = (call.arguments as? Map<*, *>)?.get("mode") as? Int ?: 0
                    rfidHandler?.scanRFID(mode)
                    result.success(true)
                }

                "startScan" -> {
                    rfidHandler?.scanRFID(1)
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
