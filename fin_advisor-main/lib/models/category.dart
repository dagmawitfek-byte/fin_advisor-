import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCodePoint; // Icons.xxx.codePoint

  @HiveField(3)
  final int colorValue; // Colors.xxx.value

  @HiveField(4)
  final bool isIncome;

  Category({
    String? id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.isIncome,
  }) : id = id ?? const Uuid().v4();

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Category copyWith({
    String? name,
    int? iconCodePoint,
    int? colorValue,
    bool? isIncome,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
