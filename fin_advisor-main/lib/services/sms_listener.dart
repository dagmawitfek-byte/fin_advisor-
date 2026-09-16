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
    
    // Initialize SMS service (sets up background listening)
    await smsService.initialize();

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

    // Start real-time monitoring
    smsService.startRealTimeMonitoring();
  }

  /// Check for pending debit messages and show dialog if found
  void _checkPendingDebits(BuildContext context) async {
    final smsService = SmsService();
    final debitMessage = await smsService.getLatestDebitMessage();

    if (debitMessage != null && context.mounted) {
      _showDebitDialog(context, debitMessage);
    }
  }

  /// Manually trigger a rescan (e.g. from a "Scan SMS" button). Returns
  /// true if a debit dialog was shown, false if nothing new was found.
  Future<bool> scanNow(BuildContext context) async {
    final smsService = SmsService();

    if (!await smsService.hasSmsPermission()) {
      final granted = await smsService.requestSmsPermission();
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SMS permission denied.')),
          );
        }
        return false;
      }
    }

    final debitMessage = await smsService.getLatestDebitMessage();
    if (debitMessage != null && context.mounted) {
      _showDebitDialog(context, debitMessage);
      return true;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No new debit transactions found in SMS.')),
      );
    }
    return false;
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

  /// Get all bank transactions
  Future<List<SmsMessage>> fetchBankTransactions() async {
    final smsService = SmsService();
    return await smsService.fetchBankSms();
  }

  /// Get debit transactions only
  Future<List<SmsMessage>> fetchDebitTransactions() async {
    final smsService = SmsService();
    return await smsService.getDebitTransactions();
  }

  /// Get credit transactions only
  Future<List<SmsMessage>> fetchCreditTransactions() async {
    final smsService = SmsService();
    return await smsService.getCreditTransactions();
  }

  /// Get latest balance
  Future<double?> getLatestBalance() async {
    final smsService = SmsService();
    return await smsService.getLatestBalance();
  }

  /// Get transactions by bank
  Future<List<SmsMessage>> getTransactionsByBank(String bankName) async {
    final smsService = SmsService();
    return await smsService.getTransactionsByBank(bankName);
  }

  /// Get transactions by period
  Future<List<SmsMessage>> getTransactionsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final smsService = SmsService();
    return await smsService.getTransactionsByPeriod(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Refresh SMS data
  Future<void> refreshSmsData() async {
    final smsService = SmsService();
    await smsService.fetchBankSms();
    print('SMS data refreshed');
  }
}
