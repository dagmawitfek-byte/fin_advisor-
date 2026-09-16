package com.finadvisor.fin_advisor

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.finadvisor.fin_advisor/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
        // Ethiopian bank keywords and patterns
        val bankKeywords = listOf(
            // Telebirr (M-Pesa equivalent in Ethiopia)
            "telebirr", "TeleBirr", "birr",
            
            // Major Ethiopian Banks
            "cbe", "commercial bank", "CBE",
            "awash", "awash bank",
            "dashen", "dashen bank",
            "addis", "addis international",
            "abyssiniabank", "abyssinia",
            "nib", "nib international",
            "united bank", "ub",
            "oromia", "oromia bank",
            "hijra", "hijra bank",
            "lion", "lion bank",
            "amhara", "amhara bank",
            
            // Transaction keywords
            "balance", "debit", "credit", "account",
            "transaction", "transfer", "payment",
            "withdrawal", "deposit", "charged",
            "available", "birr", "eth"
        )

        // Check if SMS contains bank keywords
        val bodyLower = smsBody.lowercase()
        val addressLower = smsAddress.lowercase()
        
        val containsBankKeyword = bankKeywords.any { 
            bodyLower.contains(it) || addressLower.contains(it)
        }

        // Check if SMS address looks like a bank shortcode
        val isBankShortcode = addressLower.matches(Regex("^[0-9]{3,5}$")) || 
                              addressLower.contains("bank") ||
                              addressLower.contains("telebirr")

        return containsBankKeyword || isBankShortcode
    }
}
