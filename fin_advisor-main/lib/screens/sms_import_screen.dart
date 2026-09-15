import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sms_service.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';

class SmsImportScreen extends ConsumerStatefulWidget {
  const SmsImportScreen({super.key});

  @override
  ConsumerState<SmsImportScreen> createState() => _SmsImportScreenState();
}

class _SmsImportScreenState extends ConsumerState<SmsImportScreen> {
  bool _loading = false;
  List<DetectedTransaction> _detected = [];
  final Set<int> _selected = {};

  Future<void> _scan() async {
    setState(() {
      _loading = true;
      _detected = [];
      _selected.clear();
    });

    final results = await SmsService.scanRecentSms(days: 21);

    setState(() {
      _detected = results;
      _loading = false;
      // Select all by default
      _selected.addAll(List.generate(results.length, (i) => i));
    });
  }

  Future<void> _importSelected() async {
    if (_selected.isEmpty) return;

    final accounts = ref.read(accountsProvider);
    final categories = ref.read(categoriesProvider);
    final txNotifier = ref.read(transactionsProvider.notifier);
    final accountNotifier = ref.read(accountsProvider.notifier);

    // Find a default "Other" expense/income category
    final expenseCat = categories.where((c) => !c.isIncome).firstOrNull;
    final incomeCat = categories.where((c) => c.isIncome).firstOrNull;

    for (final index in _selected) {
      final d = _detected[index];

      // Try to match account by name
      String? accountId;
      for (final a in accounts) {
        if (d.suggestedAccountName != null &&
            a.name.toLowerCase().contains(d.suggestedAccountName!.toLowerCase())) {
          accountId = a.id;
          break;
        }
      }

      final catId = d.isIncome
          ? (incomeCat?.id ?? categories.first.id)
          : (expenseCat?.id ?? categories.first.id);

      final tx = Transaction(
        title: d.title,
        amount: d.amount,
        categoryId: catId,
        date: d.date,
        isIncome: d.isIncome,
        note: d.rawBody.length > 120 ? d.rawBody.substring(0, 120) : d.rawBody,
        accountId: accountId,
      );

      await txNotifier.add(tx);

      // Update account balance if matched
      if (accountId != null) {
        final delta = d.isIncome ? d.amount : -d.amount;
        await accountNotifier.adjustBalance(accountId, delta);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported ${_selected.length} transactions')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from SMS'),
        actions: [
          if (_detected.isNotEmpty)
            TextButton(
              onPressed: _importSelected,
              child: Text('Import (${_selected.length})'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _detected.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sms_failed_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No bank / Telebirr SMS found'),
                      const SizedBox(height: 8),
                      const Text(
                        'Make sure SMS permission is granted\nand you have recent transactions.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _scan,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Scan Again'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Found ${_detected.length} possible transactions.\nSelect the ones you want to import.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _detected.length,
                        itemBuilder: (context, index) {
                          final d = _detected[index];
                          final selected = _selected.contains(index);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selected.add(index);
                                } else {
                                  _selected.remove(index);
                                }
                              });
                            },
                            title: Text(
                              d.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${Formatters.shortDate.format(d.date)} • ${d.sender}',
                            ),
                            secondary: Text(
                              '${d.isIncome ? '+' : '-'}${Formatters.money(d.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: d.isIncome
                                    ? AppTheme.incomeColor
                                    : AppTheme.expenseColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
