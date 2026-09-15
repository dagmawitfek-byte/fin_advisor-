import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../services/hive_service.dart';

final transactionBoxProvider = Provider<Box<Transaction>>((ref) {
  return HiveService.transactions;
});

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier(ref.watch(transactionBoxProvider));
});

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final Box<Transaction> _box;

  TransactionsNotifier(this._box) : super([]) {
    _load();
    _box.listenable().addListener(_load);
  }

  void _load() {
    final list = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    state = list;
  }

  Future<void> add(Transaction tx) async {
    await _box.put(tx.id, tx);
  }

  Future<void> update(Transaction tx) async {
    await _box.put(tx.id, tx);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<Transaction> getByMonth(int month, int year) {
    return state
        .where((t) => t.date.month == month && t.date.year == year)
        .toList();
  }

  double totalIncomeThisMonth() {
    final now = DateTime.now();
    return state
        .where((t) =>
            t.isIncome &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double totalExpenseThisMonth() {
    final now = DateTime.now();
    return state
        .where((t) =>
            !t.isIncome &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double balance() {
    return state.fold(
        0.0, (sum, t) => sum + (t.isIncome ? t.amount : -t.amount));
  }
}
