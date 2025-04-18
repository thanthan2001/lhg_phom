import android.content.Context
import android.util.Log
import com.rfid.trans.Reader
import com.rfid.trans.ReadTag
import com.rfid.trans.TagCallback

object RFIDManager {
    fun init(context: Context) {
        Reader.rrlib?.PowerControll(context, true)
        Log.d("RFIDManager", "RFID Powered ON")
    }

    fun stop(context: Context) {
        Reader.rrlib?.PowerControll(context, false)
        Log.d("RFIDManager", "RFID Powered OFF")
    }

    fun scanOnce(): Boolean {
        return try {
            Reader.rrlib?.ScanRfid()
            Log.d("RFIDManager", "ScanRfid() called")
            true
        } catch (e: Exception) {
            Log.e("RFIDManager", "ScanRfid() failed: ${e.message}")
            false
        }
    }

    fun startRead() {
        Reader.rrlib?.StartRead()
        Log.d("RFIDManager", "StartRead() called")
    }

    fun stopRead() {
        Reader.rrlib?.StopRead()
        Log.d("RFIDManager", "StopRead() called")
    }

    fun setCallback(callback: TagCallback) {
        Reader.rrlib?.SetCallBack(callback)
        Log.d("RFIDManager", "Callback set")
    }
}
