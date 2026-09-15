import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/bank_account.dart';
import '../services/hive_service.dart';

final accountBoxProvider = Provider<Box<BankAccount>>((ref) {
  return HiveService.accounts;
});

final accountsProvider =
    StateNotifierProvider<AccountsNotifier, List<BankAccount>>((ref) {
  return AccountsNotifier(ref.watch(accountBoxProvider));
});

class AccountsNotifier extends StateNotifier<List<BankAccount>> {
  final Box<BankAccount> _box;

  AccountsNotifier(this._box) : super([]) {
    _load();
    _box.listenable().addListener(_load);
  }

  void _load() {
    state = _box.values.toList();
  }

  Future<void> add(BankAccount account) async {
    await _box.put(account.id, account);
  }

  Future<void> update(BankAccount account) async {
    await _box.put(account.id, account);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> updateBalance(String id, double newBalance) async {
    final account = _box.get(id);
    if (account != null) {
      await _box.put(id, account.copyWith(balance: newBalance));
    }
  }

  Future<void> adjustBalance(String id, double delta) async {
    final account = _box.get(id);
    if (account != null) {
      await _box.put(id, account.copyWith(balance: account.balance + delta));
    }
  }

  double get totalBalance {
    return state.fold(0.0, (sum, a) => sum + a.balance);
  }
}
