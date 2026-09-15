import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import '../models/sms_message.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  final telephony = Telephony.instance;

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
      final sms = await telephony.getInboxSms();
      return sms.map((m) => SmsMessage.fromMap(m.toMap())).toList();
    } catch (e) {
      print('Error fetching SMS: $e');
      return [];
    }
  }

  Future<List<SmsMessage>> fetchBankSms() async {
    final allSms = await fetchAllSms();
    return allSms.where((sms) => sms.isFromBank()).toList();
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
}
