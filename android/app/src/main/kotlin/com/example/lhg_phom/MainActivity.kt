package com.example.lhg_phom

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.rfidreader.ReaderHelper
import com.rfidreader.model.ReadTag
import com.rfidreader.callback.TagCallback

class MainActivity : FlutterActivity() {

    private val CHANNEL = "rfid_channel"
    private lateinit var reader: ReaderHelper

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        reader = ReaderHelper()
        reader.PowerControll(this, true)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "scanRFID") {
                    try {
                        val tagList = mutableListOf<ReadTag>()

                        val status = reader.InventoryOnce(
                            0x00,
                            0x04,
                            0x00,
                            0x00,
                            0x80.toByte(),
                            0x00,
                            10,
                            tagList
                        )

                        if (status == 0 && tagList.isNotEmpty()) {
                            result.success(tagList[0].epcId)
                        } else {
                            result.success("Không tìm thấy thẻ")
                        }
                    } catch (e: Exception) {
                        result.error("SCAN_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        if (::reader.isInitialized) {
            reader.PowerControll(this, false)
        }
        super.onDestroy()
    }
}
