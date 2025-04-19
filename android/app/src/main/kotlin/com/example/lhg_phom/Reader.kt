package com.example.lhg_phom

import android.widget.TextView
import com.rfid.trans.ReaderHelp
import java.text.SimpleDateFormat
import java.util.Date

object Reader {
    @JvmField
    val rrlib = ReaderHelp()

    fun writeLog(log: String, tvResult: TextView) {
        val time = SimpleDateFormat("HH:mm:ss").format(Date())
        tvResult.text = "$time $log"
    }
}
