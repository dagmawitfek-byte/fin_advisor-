import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sms_message.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  static const platform = MethodChannel('com.finadvisor.fin_advisor/sms');

  SmsService._internal();

  factory SmsService() {
    return _instance;
  }

  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<bool> hasSmsPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

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

  Future<double?> getLatestBalance() async {
    final bankSms = await fetchBankSms();
    bankSms.sort((a, b) => b.date.compareTo(a.date));
    for (var message in bankSms.take(10)) {
      final balance = message.extractBalance();
      if (balance != null) return balance;
    }
    return null;
  }

  Future<SmsMessage?> getLatestDebitMessage() async {
    final bankSms = await fetchBankSms();
    bankSms.sort((a, b) => b.date.compareTo(a.date));
    for (var message in bankSms) {
      if (message.isDebitTransaction()) return message;
    }
    return null;
  }

  /// Listens for incoming SMS - Note: Real-time listening requires additional
  /// background service setup. For now, use periodic polling with fetchAllSms()
  void onSmsReceived(void Function(SmsMessage message) callback) {
    print('Real-time SMS listening requires additional background service setup.');
    print('Use fetchAllSms() or fetchBankSms() for polling-based SMS reading.');
  }
}
