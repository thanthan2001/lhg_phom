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

        // Khởi tạo RFID
        RFIDManager.init(this)

        // Đăng ký callback để nhận EPC khi đang quét liên tục
        RFIDManager.setCallback(object : TagCallback {
            override fun tagCallback(tag: ReadTag) {
                Log.d("RFID_TAG", "Callback EPC: ${tag.epcId}")
            }

            override fun StopReadCallBack() {
                Log.d("RFID_TAG", "Đã dừng quét")
            }
        })

        // Lắng nghe các phương thức từ Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scanRFID" -> {
                        val success = RFIDManager.scanOnce()
                        result.success(
                            if (success) "Đang quét..." else "Lỗi khi gọi ScanRfid"
                        )
                    }

                    "startRead" -> {
                        RFIDManager.startRead()
                        result.success("Đã bắt đầu quét liên tục")
                    }

                    "stopRead" -> {
                        RFIDManager.stopRead()
                        result.success("Đã dừng quét liên tục")
                    }

                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        RFIDManager.stop(this)
        super.onDestroy()
    }
}
