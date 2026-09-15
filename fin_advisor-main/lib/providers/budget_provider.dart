import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget.dart';
import '../services/hive_service.dart';

final budgetBoxProvider = Provider<Box<Budget>>((ref) {
  return HiveService.budgets;
});

final budgetsProvider =
    StateNotifierProvider<BudgetsNotifier, List<Budget>>((ref) {
  return BudgetsNotifier(ref.watch(budgetBoxProvider));
});

class BudgetsNotifier extends StateNotifier<List<Budget>> {
  final Box<Budget> _box;

  BudgetsNotifier(this._box) : super([]) {
    _load();
    _box.listenable().addListener(_load);
  }

  void _load() {
    state = _box.values.toList();
  }

  Future<void> add(Budget budget) async {
    await _box.put(budget.id, budget);
  }

  Future<void> update(Budget budget) async {
    await _box.put(budget.id, budget);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<Budget> getForMonth(int month, int year) {
    return state
        .where((b) => b.month == month && b.year == year)
        .toList();
  }
}
