import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'budget.g.dart';

@HiveType(typeId: 2)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double amount; // monthly limit

  @HiveField(3)
  final int month; // 1-12

  @HiveField(4)
  final int year;

  Budget({
    String? id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  }) : id = id ?? const Uuid().v4();

  Budget copyWith({
    String? categoryId,
    double? amount,
    int? month,
    int? year,
  }) {
    return Budget(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
