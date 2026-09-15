import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sms_message.dart';
import '../models/transaction.dart';
import '../services/sms_service.dart';
import '../widgets/debit_dialog.dart';

class SmsListener {
  static final SmsListener _instance = SmsListener._internal();

  factory SmsListener() {
    return _instance;
  }

  SmsListener._internal();

  /// Initialize SMS listener and check permissions
  Future<void> initialize(BuildContext context) async {
    final smsService = SmsService();
    
    // Request SMS permission
    final hasPermission = await smsService.requestSmsPermission();
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS permission denied. Enable it in settings to auto-import bank messages.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Check for pending debit transactions on first load
    _checkPendingDebits(context);
  }

  /// Check for pending debit messages and show dialog if found
  void _checkPendingDebits(BuildContext context) async {
    final smsService = SmsService();
    final debitMessage = await smsService.getLatestDebitMessage();

    if (debitMessage != null && context.mounted) {
      _showDebitDialog(context, debitMessage);
    }
  }

  /// Show debit dialog and handle the transaction saving
  void _showDebitDialog(BuildContext context, SmsMessage debitMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DebitDialog(
        debitMessage: debitMessage,
        onTransactionSaved: (Transaction transaction) {
          // Transaction is already saved in the dialog
          // Just log it for now
          print(
            'Transaction saved: ${transaction.title} - ETB ${transaction.amount} (Category: ${transaction.categoryId})',
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Transaction saved: ${transaction.title}',
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  /// Listen for new incoming SMS (background mode)
  void startListeningForNewSms(BuildContext context) {
    final smsService = SmsService();
    
    smsService.onSmsReceived((SmsMessage message) {
      if (message.isDebitTransaction() && context.mounted) {
        print('New debit SMS received: ${message.body}');
        _showDebitDialog(context, message);
      }
    });
  }
}
