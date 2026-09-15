import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'goal.g.dart';

@HiveType(typeId: 3)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  final double currentAmount;

  @HiveField(4)
  final DateTime? deadline;

  @HiveField(5)
  final int colorValue;

  @HiveField(6)
  final int iconCodePoint;

  Goal({
    String? id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    required this.colorValue,
    required this.iconCodePoint,
  }) : id = id ?? const Uuid().v4();

  double get progress =>
      targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  bool get isCompleted => currentAmount >= targetAmount;

  Goal copyWith({
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    int? colorValue,
    int? iconCodePoint,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }
}
