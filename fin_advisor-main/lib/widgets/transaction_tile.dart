import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../providers/category_provider.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';
import '../screens/add_transaction_screen.dart';

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category =
        ref.watch(categoriesProvider.notifier).getById(transaction.categoryId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddTransactionScreen(existing: transaction),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor:
              (category?.color ?? Colors.grey).withOpacity(0.2),
          child: Icon(
            category?.icon ?? Icons.category,
            color: category?.color ?? Colors.grey,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${category?.name ?? 'Unknown'} • ${Formatters.shortDate.format(transaction.date)}',
        ),
        trailing: Text(
          '${transaction.isIncome ? '+' : '-'}${Formatters.money(transaction.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transaction.isIncome
                ? AppTheme.incomeColor
                : AppTheme.expenseColor,
          ),
        ),
      ),
    );
  }
}