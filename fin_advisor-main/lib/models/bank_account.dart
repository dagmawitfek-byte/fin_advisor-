import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bank_account.g.dart';

@HiveType(typeId: 4)
class BankAccount extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name; // e.g. Telebirr, CBE, Dashen

  @HiveField(2)
  final double balance;

  @HiveField(3)
  final String? accountNumber; // last digits or full

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  final int iconCodePoint;

  @HiveField(6)
  final bool isMobileMoney; // true for Telebirr etc.

  BankAccount({
    String? id,
    required this.name,
    this.balance = 0.0,
    this.accountNumber,
    required this.colorValue,
    required this.iconCodePoint,
    this.isMobileMoney = false,
  }) : id = id ?? const Uuid().v4();

  BankAccount copyWith({
    String? name,
    double? balance,
    String? accountNumber,
    int? colorValue,
    int? iconCodePoint,
    bool? isMobileMoney,
  }) {
    return BankAccount(
      id: id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      accountNumber: accountNumber ?? this.accountNumber,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isMobileMoney: isMobileMoney ?? this.isMobileMoney,
    );
  }
}
