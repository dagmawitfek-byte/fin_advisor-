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

  // List of supported Ethiopian banks
  static const List<String> supportedBanks = [
    'CBE',
    'TELEBIRR',
    'BOA',
    'BUNNA',
    'AWASH',
    'DASHEN',
    'ADDIS',
    'NIB',
    'UNITED',
    'OROMIA',
    'HIJRA',
    'LION',
    'AMHARA',
    'ABYSSINIA'
  ];

  /// Check if SMS is from a supported Ethiopian bank
  bool isFromBank() {
    final addressUpper = address.toUpperCase();
    final bodyUpper = body.toUpperCase();

    // Check if sender name or body contains bank names
    return supportedBanks.any((bank) =>
        addressUpper.contains(bank) ||
        bodyUpper.contains(bank));
  }

  /// Get bank name from SMS sender or body
  String? getBankName() {
    final addressUpper = address.toUpperCase();
    final bodyUpper = body.toUpperCase();

    for (var bank in supportedBanks) {
      if (addressUpper.contains(bank) || bodyUpper.contains(bank)) {
        return bank;
      }
    }
    return null;
  }

  /// Categorize transaction as Debit or Credit
  TransactionType getTransactionType() {
    final bodyLower = body.toLowerCase();

    // Debit patterns
    if (bodyLower.contains('debited') ||
        bodyLower.contains('debit') ||
        bodyLower.contains('withdrawal') ||
        bodyLower.contains('payment') ||
        bodyLower.contains('transferred') ||
        bodyLower.contains('sent')) {
      return TransactionType.debit;
    }

    // Credit patterns
    if (bodyLower.contains('credited') ||
        bodyLower.contains('credit') ||
        bodyLower.contains('received') ||
        bodyLower.contains('deposit') ||
        bodyLower.contains('transferred in')) {
      return TransactionType.credit;
    }

    return TransactionType.unknown;
  }

  /// Extract transaction amount from SMS
  double? extractAmount() {
    // Try various patterns for amount extraction
    final patterns = [
      RegExp(r'(?:amount|birr|etb)[:\s]*([0-9,]+(?:\.[0-9]{2})?)', caseSensitive: false),
      RegExp(r'([0-9,]+(?:\.[0-9]{2})?)\s*(?:birr|etb)', caseSensitive: false),
      RegExp(r'debited[:\s]*([0-9,]+(?:\.[0-9]{2})?)', caseSensitive: false),
      RegExp(r'credited[:\s]*([0-9,]+(?:\.[0-9]{2})?)', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
        final amount = double.tryParse(amountStr);
        if (amount != null && amount > 0) {
          return amount;
        }
      }
    }
    return null;
  }

  /// Extract remaining balance from SMS
  double? extractBalance() {
    final patterns = [
      RegExp(r'(?:balance|bal)[:\s]*([0-9,]+(?:\.[0-9]{2})?)', caseSensitive: false),
      RegExp(r'(?:available)[:\s]*([0-9,]+(?:\.[0-9]{2})?)', caseSensitive: false),
      RegExp(r'(?:remaining)[:\s]*([0-9,]+(?:\.[0-9]{2})?)', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final balanceStr = match.group(1)?.replaceAll(',', '') ?? '';
        final balance = double.tryParse(balanceStr);
        if (balance != null && balance >= 0) {
          return balance;
        }
      }
    }
    return null;
  }

  /// Check if this is a debit transaction
  bool isDebitTransaction() {
    return getTransactionType() == TransactionType.debit;
  }

  /// Check if this is a credit transaction
  bool isCreditTransaction() {
    return getTransactionType() == TransactionType.credit;
  }

  @override
  String toString() => 'SmsMessage(from: $address, date: $date, type: ${getTransactionType()})';
}

enum TransactionType {
  debit,
  credit,
  unknown,
}
