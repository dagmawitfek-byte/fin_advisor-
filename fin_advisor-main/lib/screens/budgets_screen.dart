import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/budget.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final budgets = ref.watch(budgetsProvider)
        .where((b) => b.month == now.month && b.year == now.year)
        .toList();
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Budgets • ${Formatters.monthYear.format(now)}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No budgets set for this month'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => _showAddBudgetDialog(context, ref),
                    child: const Text('Create Budget'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                final category = categories
                    .where((c) => c.id == budget.categoryId)
                    .firstOrNull;

                // Calculate spent
                final spent = transactions
                    .where((t) =>
                        !t.isIncome &&
                        t.categoryId == budget.categoryId &&
                        t.date.month == now.month &&
                        t.date.year == now.year)
                    .fold(0.0, (sum, t) => sum + t.amount);

                final progress = (spent / budget.amount).clamp(0.0, 1.5);
                final isOver = spent > budget.amount;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  (category?.color ?? Colors.grey).withOpacity(0.2),
                              child: Icon(
                                category?.icon ?? Icons.category,
                                color: category?.color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category?.name ?? 'Unknown',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),
                            Text(
                              '${Formatters.compactMoney(spent)} / ${Formatters.compactMoney(budget.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isOver
                                    ? AppTheme.expenseColor
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress > 1 ? 1 : progress,
                          backgroundColor: Colors.grey.shade300,
                          color: isOver
                              ? AppTheme.expenseColor
                              : (category?.color ?? AppTheme.primaryColor),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        if (isOver)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Over budget by ${Formatters.money(spent - budget.amount)}',
                              style: TextStyle(
                                color: AppTheme.expenseColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    final categories = ref
        .read(categoriesProvider)
        .where((c) => !c.isIncome)
        .toList();
    String? selectedId;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (v) => selectedId = v,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Monthly Limit',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (selectedId == null || amountController.text.isEmpty) return;
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) return;

              final now = DateTime.now();
              await ref.read(budgetsProvider.notifier).add(Budget(
                    categoryId: selectedId!,
                    amount: amount,
                    month: now.month,
                    year: now.year,
                  ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}