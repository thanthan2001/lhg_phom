package com.example.lhg_phom

import android.content.Context
import android.media.AudioManager
import android.media.SoundPool
import android.os.Handler
import android.os.Looper
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

  

    private fun initSound() {
        soundPool = SoundPool(1, AudioManager.STREAM_MUSIC, 0)
        soundId = soundPool?.load(context, R.raw.barcodebeep, 1)

        soundId?.let {
            Reader.rrlib.SetSoundID(it, soundPool)
            Log.d("RFID", "🎵 Sound initialized")
        } ?: Log.w("RFID", "⚠️ Sound init failed")
    }

    fun connect(): Boolean {
        val result = Reader.rrlib.Connect("/dev/ttyHSL0", 115200, 0)
        return if (result == 0) {
  
            Log.d("RFID", "✅ Connected successfully")
  
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onConnected", null)
            }
            true
        } else {
            Log.e("RFID", "❌ Connection failed: $result")
  
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onError", "Connection failed: $result")
            }
            false
        }
    }

    fun disconnect() {
        try {
            Reader.rrlib.StopRead()
  
            Reader.rrlib.DisConnect()
            Log.d("RFID", "🔌 Disconnected")
        } catch (e: Exception) {
            Log.w("RFID", "⚠️ Disconnect failed: ${e.message}")
        }
    }

    fun scanRFID(mode: Int) {
        Reader.rrlib.SetCallBack(object : TagCallback {
  
            override fun tagCallback(tag: ReadTag?) {
                tag?.epcId?.let { epc ->
  
                    Log.d("RFID", "📦 Tag scanned on background thread: $epc")

  
  
                    Handler(Looper.getMainLooper()).post {
  
  
                        Log.d("RFID", "🚀 Sending tag to Flutter on main thread: $epc")
                        channel.invokeMethod("onTagScanned", epc)
                    }
  
                }
            }

  
            override fun StopReadCallBack() {
                Handler(Looper.getMainLooper()).post {
                    Log.d("RFID", "🛑 Scan stopped callback received")
  
  
                }
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
                    Handler(Looper.getMainLooper()).post {
                        channel.invokeMethod("onContinuousScanStart", null)
                    }
                } else {
                    Log.e("RFID", "❌ Failed to start scan: $result")
                    Handler(Looper.getMainLooper()).post {
                        channel.invokeMethod("onError", "StartRead failed: $result")
                    }
                }
            }
            else -> {
                Log.w("RFID", "⚠️ Unknown scan mode: $mode")
            }
        }
    }

    fun stopScan() {
        Reader.rrlib.StopRead()
        Log.d("RFID", "⏹️ Scan stopped by user")
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod("onScanStopped", null)
        }
    }
}