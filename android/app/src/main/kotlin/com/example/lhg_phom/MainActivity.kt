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
    
    // Khai báo methodChannel ở đây để có thể truy cập từ onKeyDown
    private lateinit var methodChannel: MethodChannel 

    // Thay 523 bằng mã phím của bạn nếu nó khác
    private val SCAN_KEYCODE = 523

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Khởi tạo methodChannel đã khai báo ở trên
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
        // Log để debug tất cả các lần nhấn phím
        Log.d("HardwareKey", "Key Event -> Code: $keyCode, Repeat Count: ${event.repeatCount}")

        // Kiểm tra xem có phải là nút scan không VÀ chỉ xử lý ở lần nhấn đầu tiên
        if (keyCode == SCAN_KEYCODE && event.repeatCount == 0) {
            Log.d("HardwareKey", "✅ Scan button pressed! Sending event to Flutter.")
            
            // Gửi một tín hiệu sang phía Dart.
            // Bọc trong runOnUiThread để đảm bảo 100% an toàn về luồng.
            runOnUiThread {
                methodChannel.invokeMethod("onScanButtonPressed", null)
            }
            
            // Trả về true để báo rằng sự kiện này đã được xử lý xong ở đây,
            // hệ thống không cần làm gì thêm.
            return true 
        }
        
        // Đối với các phím khác hoặc các sự kiện lặp lại, để hệ thống xử lý mặc định.
        return super.onKeyDown(keyCode, event)
    }
}