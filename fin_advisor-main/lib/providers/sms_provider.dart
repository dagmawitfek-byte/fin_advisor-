import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sms_message.dart';
import '../services/sms_service.dart';

final smsServiceProvider = Provider((ref) => SmsService());

final bankSmsProvider = FutureProvider<List<SmsMessage>>((ref) async {
  final smsService = ref.watch(smsServiceProvider);
  return smsService.fetchBankSms();
});

final latestBalanceProvider = FutureProvider<double?>((ref) async {
  final smsService = ref.watch(smsServiceProvider);
  return smsService.getLatestBalance();
});

final latestDebitProvider = FutureProvider<SmsMessage?>((ref) async {
  final smsService = ref.watch(smsServiceProvider);
  return smsService.getLatestDebitMessage();
});
