import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category.dart';
import '../services/hive_service.dart';

final categoryBoxProvider = Provider<Box<Category>>((ref) {
  return HiveService.categories;
});

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier(ref.watch(categoryBoxProvider));
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  final Box<Category> _box;

  CategoriesNotifier(this._box) : super([]) {
    _load();
    _box.listenable().addListener(_load);
  }

  void _load() {
    state = _box.values.toList();
  }

  Future<void> add(Category cat) async {
    await _box.put(cat.id, cat);
  }

  Future<void> update(Category cat) async {
    await _box.put(cat.id, cat);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Category? getById(String id) {
    return _box.get(id);
  }

  List<Category> get expenseCategories =>
      state.where((c) => !c.isIncome).toList();

  List<Category> get incomeCategories =>
      state.where((c) => c.isIncome).toList();
}
