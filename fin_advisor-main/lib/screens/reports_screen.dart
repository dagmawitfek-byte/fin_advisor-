import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final now = DateTime.now();

    // Expense by category this month
    final monthExpenses = transactions.where((t) =>
        !t.isIncome &&
        t.date.month == now.month &&
        t.date.year == now.year);

    final Map<String, double> byCategory = {};
    for (final t in monthExpenses) {
      byCategory[t.categoryId] = (byCategory[t.categoryId] ?? 0) + t.amount;
    }

    final pieSections = <PieChartSectionData>[];
    final totalExpense = byCategory.values.fold(0.0, (a, b) => a + b);

    int i = 0;
    byCategory.forEach((catId, amount) {
      final cat = categories.where((c) => c.id == catId).firstOrNull;
      final percent = totalExpense == 0 ? 0 : (amount / totalExpense * 100);
      pieSections.add(PieChartSectionData(
        value: amount,
        title: '${percent.toStringAsFixed(0)}%',
        color: cat?.color ?? Colors.primaries[i % Colors.primaries.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      i++;
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Spending by Category',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.monthYear.format(now),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          if (pieSections.isEmpty)
            const SizedBox(
              height: 200,
              child: Center(child: Text('No expenses this month')),
            )
          else
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Legend
          ...byCategory.entries.map((e) {
            final cat = categories.where((c) => c.id == e.key).firstOrNull;
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 10,
                backgroundColor: cat?.color ?? Colors.grey,
              ),
              title: Text(cat?.name ?? 'Unknown'),
              trailing: Text(
                Formatters.money(e.value),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }),

          const SizedBox(height: 32),
          Text(
            'Monthly Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _MonthlyBarChart(transactions: transactions),
        ],
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final List transactions;

  const _MonthlyBarChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Last 6 months
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final date = DateTime(now.year, now.month - (5 - i), 1);
      return date;
    });

    final incomeData = <double>[];
    final expenseData = <double>[];

    for (final m in months) {
      double inc = 0;
      double exp = 0;
      for (final t in transactions) {
        if (t.date.month == m.month && t.date.year == m.year) {
          if (t.isIncome) {
            inc += t.amount;
          } else {
            exp += t.amount;
          }
        }
      }
      incomeData.add(inc);
      expenseData.add(exp);
    }

    final maxY = [...incomeData, ...expenseData].fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = maxY == 0 ? 1000.0 : maxY * 1.2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          barGroups: List.generate(6, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: incomeData[i],
                  color: AppTheme.incomeColor,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: expenseData[i],
                  color: AppTheme.expenseColor,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final m = months[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      Formatters.shortDate.format(m).split(' ')[0],
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}