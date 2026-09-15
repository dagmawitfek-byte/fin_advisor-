import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/bank_account.dart';

class HiveService {
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String budgetsBox = 'budgets';
  static const String goalsBox = 'goals';
  static const String accountsBox = 'accounts';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(BankAccountAdapter());

    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<Category>(categoriesBox);
    await Hive.openBox<Budget>(budgetsBox);
    await Hive.openBox<Goal>(goalsBox);
    await Hive.openBox<BankAccount>(accountsBox);

    // Seed default categories if empty
    final catBox = Hive.box<Category>(categoriesBox);
    if (catBox.isEmpty) {
      await _seedDefaultCategories(catBox);
    }
  }

  static Future<void> _seedDefaultCategories(Box<Category> box) async {
    final defaults = [
      // Expenses
      Category(
        name: 'Food & Dining',
        iconCodePoint: 0xe56c,
        colorValue: 0xFFFF7043,
        isIncome: false,
      ),
      Category(
        name: 'Transport',
        iconCodePoint: 0xe530,
        colorValue: 0xFF42A5F5,
        isIncome: false,
      ),
      Category(
        name: 'Shopping',
        iconCodePoint: 0xe8cc,
        colorValue: 0xFFAB47BC,
        isIncome: false,
      ),
      Category(
        name: 'Bills & Utilities',
        iconCodePoint: 0xe0c3,
        colorValue: 0xFFEF5350,
        isIncome: false,
      ),
      Category(
        name: 'Entertainment',
        iconCodePoint: 0xe40a,
        colorValue: 0xFF26A69A,
        isIncome: false,
      ),
      Category(
        name: 'Health',
        iconCodePoint: 0xe0d0,
        colorValue: 0xFFEC407A,
        isIncome: false,
      ),
      Category(
        name: 'Education',
        iconCodePoint: 0xe80c,
        colorValue: 0xFF5C6BC0,
        isIncome: false,
      ),
      Category(
        name: 'Other',
        iconCodePoint: 0xe8b6,
        colorValue: 0xFF78909C,
        isIncome: false,
      ),
      // Income
      Category(
        name: 'Salary',
        iconCodePoint: 0xe227,
        colorValue: 0xFF66BB6A,
        isIncome: true,
      ),
      Category(
        name: 'Freelance',
        iconCodePoint: 0xe8f9,
        colorValue: 0xFF26C6DA,
        isIncome: true,
      ),
      Category(
        name: 'Investments',
        iconCodePoint: 0xe1b0,
        colorValue: 0xFFFFCA28,
        isIncome: true,
      ),
      Category(
        name: 'Other Income',
        iconCodePoint: 0xe8e5,
        colorValue: 0xFF9CCC65,
        isIncome: true,
      ),
    ];

    for (final cat in defaults) {
      await box.put(cat.id, cat);
    }
  }

  // Convenience getters
  static Box<Transaction> get transactions =>
      Hive.box<Transaction>(transactionsBox);
  static Box<Category> get categories => Hive.box<Category>(categoriesBox);
  static Box<Budget> get budgets => Hive.box<Budget>(budgetsBox);
  static Box<Goal> get goals => Hive.box<Goal>(goalsBox);
  static Box<BankAccount> get accounts => Hive.box<BankAccount>(accountsBox);
}
