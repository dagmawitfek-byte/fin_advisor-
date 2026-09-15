import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SmsMessage {
  final String id;
  final String address;
  final String body;
  final DateTime date;
  final int type;

  SmsMessage({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
    required this.type,
  });

  factory SmsMessage.fromMap(Map<String, dynamic> map) {
    return SmsMessage(
      id: map['_id'] ?? '',
      address: map['address'] ?? '',
      body: map['body'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      type: map['type'] ?? 1,
    );
  }

  bool isFromBank() {
    final bankKeywords = ['bank', 'telebirr', 'awash', 'dashen', 'abysinia', 'oromia', 'nib', 'cbe', 'balance', 'transaction', 'debit', 'credit'];
    return bankKeywords.any((keyword) => address.toLowerCase().contains(keyword) || body.toLowerCase().contains(keyword));
  }

  double? extractBalance() {
    final balancePattern = RegExp(r'(?:balance|bal)[:\s]*([0-9,]+(?:\.[0-9]{2})?)');
    final match = balancePattern.firstMatch(body.toLowerCase());
    if (match != null) {
      final balanceStr = match.group(1)?.replaceAll(',', '') ?? '';
      return double.tryParse(balanceStr);
    }
    return null;
  }

  bool isDebitTransaction() {
    return body.toLowerCase().contains('debit') || body.toLowerCase().contains('withdrawal') || body.toLowerCase().contains('payment');
  }

  double? extractAmount() {
    final amountPattern = RegExp(r'(?:amount|birr|etb)[:\s]*([0-9,]+(?:\.[0-9]{2})?)');
    final match = amountPattern.firstMatch(body.toLowerCase());
    if (match != null) {
      final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
      return double.tryParse(amountStr);
    }
    return null;
  }
}
