import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal.dart';
import '../services/hive_service.dart';

final goalBoxProvider = Provider<Box<Goal>>((ref) {
  return HiveService.goals;
});

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier(ref.watch(goalBoxProvider));
});

class GoalsNotifier extends StateNotifier<List<Goal>> {
  final Box<Goal> _box;

  GoalsNotifier(this._box) : super([]) {
    _load();
    _box.listenable().addListener(_load);
  }

  void _load() {
    state = _box.values.toList();
  }

  Future<void> add(Goal goal) async {
    await _box.put(goal.id, goal);
  }

  Future<void> update(Goal goal) async {
    await _box.put(goal.id, goal);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> addAmount(String id, double amount) async {
    final goal = _box.get(id);
    if (goal != null) {
      final updated = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );
      await _box.put(id, updated);
    }
  }
}
