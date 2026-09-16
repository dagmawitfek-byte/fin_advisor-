package com.finadvisor.fin_advisor

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            for (message in messages) {
                val sender = message.originatingAddress ?: return
                val body = message.messageBody
                val timestamp = message.timestampMillis

                // Check if SMS is from bank
                if (isFromBank(body, sender)) {
                    Log.d("SmsReceiver", "Bank SMS received from: $sender")
                    // Show notification/popup
                    showTransactionNotification(context, sender, body, timestamp)
                }
            }
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

    private fun showTransactionNotification(
        context: Context?,
        sender: String,
        body: String,
        timestamp: Long
    ) {
        try {
            context?.let {
                val intent = Intent(it, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("sms_sender", sender)
                    putExtra("sms_body", body)
                    putExtra("sms_timestamp", timestamp)
                    putExtra("show_transaction_dialog", true)
                }
                it.startActivity(intent)
            }
        } catch (e: Exception) {
            Log.e("SmsReceiver", "Error showing notification: ${e.message}")
        }
    }

    companion object {
        fun setupBackgroundMonitoring(context: Context) {
            try {
                val receiver = SmsReceiver()
                val filter = IntentFilter().apply {
                    addAction(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    context.registerReceiver(
                        receiver,
                        filter,
                        Context.RECEIVER_EXPORTED
                    )
                } else {
                    @Suppress("UnspecifiedRegisterReceiverFlag")
                    context.registerReceiver(receiver, filter)
                }

                Log.d("SmsReceiver", "Background SMS monitoring setup complete")
            } catch (e: Exception) {
                Log.e("SmsReceiver", "Error setting up background monitoring: ${e.message}")
            }
        }
    }
}
