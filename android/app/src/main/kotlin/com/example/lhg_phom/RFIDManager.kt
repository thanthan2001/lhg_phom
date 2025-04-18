package com.example.lhg_phom

import android.content.Context
import com.rfid.trans.ReaderHelp
import com.rfid.trans.ReadTag
import com.rfid.trans.TagCallback

object RFIDManager {
    private var reader: ReaderHelp? = null

    fun initialize(context: Context) {
        reader = ReaderHelp()
        reader?.PowerControll(context, true)
    }

    fun destroy(context: Context) {
        reader?.PowerControll(context, false)
    }

    fun scanOnce(): String? {
        val tagList = mutableListOf<ReadTag>()
        val status = reader?.InventoryOnce(
            0x00, 0x04, 0x00, 0x00,
            0x80.toByte(), 0x00, 10, tagList
        )
        return if (status == 0 && tagList.isNotEmpty()) {
            tagList[0].epcId
        } else {
            null
        }
    }

    fun setCallback(callback: TagCallback) {
        reader?.SetCallBack(callback)
    }
}
