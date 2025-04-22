package com.example.lhg_phom

import android.content.Context
import android.media.AudioManager
import android.media.SoundPool
import android.util.Log
import com.rfid.trans.ReadTag
import com.rfid.trans.ReaderParameter
import com.rfid.trans.TagCallback
import io.flutter.plugin.common.MethodChannel

class RFIDHandler(
    private val context: Context,
    private val channel: MethodChannel
) {
    private var soundPool: SoundPool? = null
    private var soundId: Int? = null

    // 🔊 Khởi tạo âm thanh
    private fun initSound() {
        soundPool = SoundPool(1, AudioManager.STREAM_MUSIC, 0)
        soundId = soundPool?.load(context, R.raw.barcodebeep, 1)

        soundId?.let {
            Reader.rrlib.SetSoundID(it, soundPool)
            Log.d("RFID", "🎵 Sound initialized")
        } ?: Log.w("RFID", "⚠️ Sound init failed")
    }

    // 🔌 Kết nối RFID
    fun connect(): Boolean {
        try {
            Reader.rrlib.PowerControll(null, true)
            Thread.sleep(1500)
            Log.d("RFID", "🔌 PowerOn success")
        } catch (e: Exception) {
            Log.w("RFID", "⚠️ PowerControll failed: ${e.message}")
        }

        val result = Reader.rrlib.Connect("/dev/ttyHSL0", 115200, 0)

        return if (result == 0) {
            Log.d("RFID", "✅ Connected successfully")
            initSound()
            channel.invokeMethod("onConnected", null)
            true
        } else {
            Log.e("RFID", "❌ Connection failed: $result")
            channel.invokeMethod("onError", "Connection failed: $result")
            false
        }
    }

    // 🔌 Ngắt kết nối
    fun disconnect() {
        try {
            Reader.rrlib.PowerControll(null, false)
        } catch (e: Exception) {
            Log.w("RFID", "⚠️ PowerOff failed: ${e.message}")
        }

        Reader.rrlib.DisConnect()
        Log.d("RFID", "🔌 Disconnected")
    }

    // 📡 Quét RFID
    fun scanRFID(mode: Int) {
        Reader.rrlib.SetCallBack(object : TagCallback {
            override fun tagCallback(tag: ReadTag?) {
                tag?.epcId?.let {
                    Log.d("RFID", "📦 Tag scanned: $it")
                    channel.invokeMethod("onTagScanned", it)
                }
            }

            override fun StopReadCallBack() {
                Log.d("RFID", "🛑 Scan stopped")
            }
        })

        val param = Reader.rrlib.GetInventoryPatameter()
        param.Session = 0
        param.QValue = 4
        Reader.rrlib.SetInventoryPatameter(param)

        when (mode) {
            0 -> {
                Log.d("RFID", "▶️ Scan single tag")
                Reader.rrlib.ScanRfid()
            }
            1 -> {
                val result = Reader.rrlib.StartRead()
                if (result == 0) {
                    Log.d("RFID", "🔄 Continuous scan started")
                    channel.invokeMethod("onContinuousScanStart", null)
                } else {
                    Log.e("RFID", "❌ Failed to start scan: $result")
                    channel.invokeMethod("onError", "StartRead failed: $result")
                }
            }
            else -> {
                Log.w("RFID", "⚠️ Unknown scan mode: $mode")
            }
        }
    }

    // ⏹️ Dừng quét
    fun stopScan() {
        Reader.rrlib.StopRead()
        Log.d("RFID", "⏹️ Scan stopped by user")
        channel.invokeMethod("onScanStopped", null)
    }
}
