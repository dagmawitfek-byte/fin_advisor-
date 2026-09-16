package com.finadvisor.fin_advisor

import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.finadvisor.fin_advisor/sms"
    private val BACKGROUND_CHANNEL = "com.finadvisor.fin_advisor/background"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // SMS Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "fetchAllSms" -> {
                        try {
                            val smsMessages = fetchAllSms()
                            result.success(smsMessages)
                        } catch (e: Exception) {
                            result.error("SMS_ERROR", e.message, null)
                        }
                    }
                    "fetchBankSms" -> {
                        try {
                            val bankSms = fetchBankSms()
                            result.success(bankSms)
                        } catch (e: Exception) {
                            result.error("SMS_ERROR", e.message, null)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }

        // Background monitoring channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKGROUND_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setupBackgroundListener" -> {
                        try {
                            SmsReceiver.setupBackgroundMonitoring(this)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("BG_ERROR", e.message, null)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun fetchAllSms(): List<Map<String, Any?>> {
        val smsList = mutableListOf<Map<String, Any?>>()
        val resolver: ContentResolver = contentResolver
        val uri: Uri = Telephony.Sms.CONTENT_URI

        val cursor: Cursor? = resolver.query(
            uri,
            arrayOf("_id", "address", "body", "date", "type"),
            null,
            null,
            "date DESC"
        )

        cursor?.use {
            while (it.moveToNext()) {
                val id = it.getString(0)
                val address = it.getString(1)
                val body = it.getString(2)
                val date = it.getLong(3)
                val type = it.getInt(4)

                smsList.add(
                    mapOf(
                        "_id" to id,
                        "address" to address,
                        "body" to body,
                        "date" to date,
                        "type" to type
                    )
                )
            }
        }

        return smsList
    }

    private fun fetchBankSms(): List<Map<String, Any?>> {
        val allSms = fetchAllSms()
        return allSms.filter { sms ->
            val body = sms["body"] as? String ?: ""
            val address = sms["address"] as? String ?: ""
            isFromBank(body, address)
        }
    }

    private fun isFromBank(smsBody: String, smsAddress: String): Boolean {
        val supportedBanks = listOf(
            "CBE", "TELEBIRR", "BOA", "BUNNA", "AWASH", "DASHEN",
            "ADDIS", "NIB", "UNITED", "OROMIA", "HIJRA", "LION", "AMHARA", "ABYSSINIA"
        )

        val bodyUpper = smsBody.uppercase()
        val addressUpper = smsAddress.uppercase()

        return supportedBanks.any { bank ->
            bodyUpper.contains(bank) || addressUpper.contains(bank)
        }
    }
}
