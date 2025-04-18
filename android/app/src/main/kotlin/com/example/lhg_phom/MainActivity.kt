package com.example.lhg_phom

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.rfid.trans.ReadTag
import com.rfid.trans.TagCallback

class MainActivity : FlutterActivity() {
    private val CHANNEL = "rfid_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Khởi tạo thiết bị
        RFIDManager.initialize(this)

        // Đăng ký callback nhận thẻ
        RFIDManager.setCallback(object : TagCallback {
            override fun tagCallback(tag: ReadTag) {
                Log.d("RFID_TAG", "Đã đọc thẻ: ${tag.epcId}")
            }

            override fun StopReadCallBack() {
                Log.d("RFID_TAG", "Đã dừng đọc")
            }
        })

        // Xử lý lệnh từ Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scanRFID" -> {
                        val epc = RFIDManager.scanOnce()
                        result.success(epc ?: "Không tìm thấy thẻ")
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        RFIDManager.destroy(this)
        super.onDestroy()
    }
}
