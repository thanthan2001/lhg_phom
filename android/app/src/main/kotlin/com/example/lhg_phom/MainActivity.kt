package com.example.lhg_phom

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.util.Log
import android.view.KeyEvent

class MainActivity : FlutterActivity() {
    private val CHANNEL = "rfid_channel"
    private var rfidHandler: RFIDHandler? = null
    
  
    private lateinit var methodChannel: MethodChannel 

  
    private val SCAN_KEYCODE = 523

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

  
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
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

    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
  
        Log.d("HardwareKey", "Key Event -> Code: $keyCode, Repeat Count: ${event.repeatCount}")

  
        if (keyCode == SCAN_KEYCODE && event.repeatCount == 0) {
            Log.d("HardwareKey", "✅ Scan button pressed! Sending event to Flutter.")
            
  
  
            runOnUiThread {
                methodChannel.invokeMethod("onScanButtonPressed", null)
            }
            
  
  
            return true 
        }
        
  
        return super.onKeyDown(keyCode, event)
    }
}