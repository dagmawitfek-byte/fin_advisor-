import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final bool isIncome; // true = income, false = expense

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final String? accountId; // link to BankAccount

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.isIncome,
    this.note,
    this.accountId,
  }) : id = id ?? const Uuid().v4();

  Transaction copyWith({
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    bool? isIncome,
    String? note,
    String? accountId,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      note: note ?? this.note,
      accountId: accountId ?? this.accountId,
    );
  }
}
