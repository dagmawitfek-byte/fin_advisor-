import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sms_message.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  static const platform = MethodChannel('com.finadvisor.fin_advisor/sms');
  static const backgroundChannel =
      MethodChannel('com.finadvisor.fin_advisor/background');

  bool _isInitialized = false;

  SmsService._internal();

  factory SmsService() {
    return _instance;
  }

  /// Initialize SMS monitoring on app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await requestSmsPermission();

      // Setup background SMS listener
      await setupBackgroundListener();

      _isInitialized = true;
      print('SMS Service initialized successfully');
    } catch (e) {
      print('Error initializing SMS Service: $e');
    }
  }

  /// Request SMS and notification permissions
  Future<bool> requestSmsPermission() async {
    try {
      final smsStatus = await Permission.sms.request();
      final notificationStatus =
          await Permission.notification.request();

      return smsStatus.isGranted && notificationStatus.isGranted;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Check if SMS permission is granted
  Future<bool> hasSmsPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Setup background SMS listener
  Future<void> setupBackgroundListener() async {
    try {
      await backgroundChannel.invokeMethod('setupBackgroundListener');
      print('Background SMS listener setup successfully');
    } catch (e) {
      print('Error setting up background listener: $e');
    }
  }

  /// Fetch all SMS messages
  Future<List<SmsMessage>> fetchAllSms() async {
    try {
      if (!await hasSmsPermission()) {
        final granted = await requestSmsPermission();
        if (!granted) return [];
      }

      final List<dynamic> result =
          await platform.invokeMethod('fetchAllSms');

      return result.map((sms) {
        return SmsMessage.fromMap(Map<String, dynamic>.from(sms));
      }).toList();
    } on PlatformException catch (e) {
      print('Error fetching SMS: ${e.message}');
      return [];
    } catch (e) {
      print('Error fetching SMS: $e');
      return [];
    }
  }

  /// Fetch bank SMS messages only
  Future<List<SmsMessage>> fetchBankSms() async {
    try {
      if (!await hasSmsPermission()) {
        final granted = await requestSmsPermission();
        if (!granted) return [];
      }

      final List<dynamic> result =
          await platform.invokeMethod('fetchBankSms');

      return result.map((sms) {
        return SmsMessage.fromMap(Map<String, dynamic>.from(sms));
      }).toList();
    } on PlatformException catch (e) {
      print('Error fetching bank SMS: ${e.message}');
      return [];
    } catch (e) {
      print('Error fetching bank SMS: $e');
      return [];
    }
  }

  /// Get latest bank balance
  Future<double?> getLatestBalance() async {
    final bankSms = await fetchBankSms();
    if (bankSms.isEmpty) return null;

    // Sort by date, newest first
    bankSms.sort((a, b) => b.date.compareTo(a.date));

    // Check last 20 SMS for balance
    for (var message in bankSms.take(20)) {
      final balance = message.extractBalance();
      if (balance != null) return balance;
    }

    return null;
  }

  /// Get latest debit transaction
  Future<SmsMessage?> getLatestDebitMessage() async {
    final bankSms = await fetchBankSms();
    if (bankSms.isEmpty) return null;

    // Sort by date, newest first
    bankSms.sort((a, b) => b.date.compareTo(a.date));

    for (var message in bankSms) {
      if (message.isDebitTransaction()) return message;
    }

    return null;
  }

  /// Get latest credit transaction
  Future<SmsMessage?> getLatestCreditMessage() async {
    final bankSms = await fetchBankSms();
    if (bankSms.isEmpty) return null;

    // Sort by date, newest first
    bankSms.sort((a, b) => b.date.compareTo(a.date));

    for (var message in bankSms) {
      if (message.isCreditTransaction()) return message;
    }

    return null;
  }

  /// Get transactions for a specific period
  Future<List<SmsMessage>> getTransactionsByPeriod(
      {required DateTime startDate, required DateTime endDate}) async {
    final bankSms = await fetchBankSms();
    return bankSms
        .where((sms) => sms.date.isAfter(startDate) && sms.date.isBefore(endDate))
        .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get transactions by bank
  Future<List<SmsMessage>> getTransactionsByBank(String bankName) async {
    final bankSms = await fetchBankSms();
    return bankSms
        .where((sms) => sms.getBankName()?.toUpperCase() == bankName.toUpperCase())
        .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get debit transactions
  Future<List<SmsMessage>> getDebitTransactions() async {
    final bankSms = await fetchBankSms();
    return bankSms
        .where((sms) => sms.isDebitTransaction())
        .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get credit transactions
  Future<List<SmsMessage>> getCreditTransactions() async {
    final bankSms = await fetchBankSms();
    return bankSms
        .where((sms) => sms.isCreditTransaction())
        .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Real-time SMS monitoring is handled by native background service
  /// Check MainActivity for background SMS receiver implementation
  void startRealTimeMonitoring() {
    print('Real-time SMS monitoring active in background');
  }

  void stopRealTimeMonitoring() {
    print('Real-time SMS monitoring stopped');
  }
}
