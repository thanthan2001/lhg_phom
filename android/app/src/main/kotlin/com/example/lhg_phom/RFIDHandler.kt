package com.example.lhg_phom

import android.content.Context
import android.util.Log

import com.rfid.trans.ReaderParameter
import com.rfid.trans.ReadTag;
import com.rfid.trans.TagCallback;
import io.flutter.plugin.common.MethodChannel

class RFIDHandler(
    private val context: Context,
    private val channel: MethodChannel
) {
    fun connect(): Boolean {
        try {
            Reader.rrlib.PowerControll(null, true)
        } catch (e: Exception) {
            Log.w("RFID", "PowerControll failed: ${e.message}")
        }

        val result = Reader.rrlib.Connect("/dev/ttyHSL0", 115200, 0)
        
        if (result == 0) {
            Log.d("RFID", "Connected successfully")
            channel.invokeMethod("onConnected", null)
            return true
        } else {
            Log.e("RFID", "Connection failed: $result")
            channel.invokeMethod("onError", "Connection failed: $result")
            return false
        }
    }

    fun disconnect() {
        Reader.rrlib.PowerControll(null, false)

        Reader.rrlib.DisConnect()
    }

    fun startScan() {
        Reader.rrlib.SetCallBack(object : TagCallback {
            override fun tagCallback(tag: ReadTag?) {
                tag?.epcId?.let {
                    Log.d("RFID", "Tag scanned: $it")
                    channel.invokeMethod("onTagScanned", it)
                }
            }

            override fun StopReadCallBack() {
                Log.d("RFID", "Scan stopped")
            }
        })

        val param = Reader.rrlib.GetInventoryPatameter()
        param.Session = 0
        param.QValue = 4
        Reader.rrlib.SetInventoryPatameter(param)
        Reader.rrlib.StartRead()
    }

    fun stopScan() {
        Reader.rrlib.StopRead()
    }
}
