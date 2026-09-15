import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bank_account.dart';
import '../providers/account_provider.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';
import 'sms_import_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final total = ref.watch(accountsProvider.notifier).totalBalance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sms_outlined),
            tooltip: 'Scan SMS',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SmsImportScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Total Balance Card
          Card(
            margin: const EdgeInsets.all(16),
            color: AppTheme.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.money(total),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: accounts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No accounts yet'),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => _showAddAccountDialog(context, ref),
                          child: const Text('Add Telebirr / Bank'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Color(account.colorValue).withOpacity(0.2),
                            child: Icon(
                              IconData(account.iconCodePoint,
                                  fontFamily: 'MaterialIcons'),
                              color: Color(account.colorValue),
                            ),
                          ),
                          title: Text(
                            account.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: account.accountNumber != null
                              ? Text('•••• ${account.accountNumber}')
                              : null,
                          trailing: Text(
                            Formatters.money(account.balance),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () =>
                              _showEditBalanceDialog(context, ref, account),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final numberController = TextEditingController();
    bool isMobileMoney = true;
    int selectedColor = 0xFF00A651; // Telebirr green-ish
    int selectedIcon = 0xe0cd; // phone_android

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name (Telebirr, CBE, Dashen...)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Current Balance',
                    prefixText: 'ETB ',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(
                    labelText: 'Account / Phone (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Mobile Money (Telebirr)'),
                  value: isMobileMoney,
                  onChanged: (v) => setState(() => isMobileMoney = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final balance =
                    double.tryParse(balanceController.text) ?? 0.0;
                if (name.isEmpty) return;

                await ref.read(accountsProvider.notifier).add(BankAccount(
                      name: name,
                      balance: balance,
                      accountNumber: numberController.text.trim().isEmpty
                          ? null
                          : numberController.text.trim(),
                      colorValue: selectedColor,
                      iconCodePoint: selectedIcon,
                      isMobileMoney: isMobileMoney,
                    ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBalanceDialog(
      BuildContext context, WidgetRef ref, BankAccount account) {
    final controller =
        TextEditingController(text: account.balance.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update ${account.name} Balance'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Balance',
            prefixText: 'ETB ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value == null) return;
              await ref
                  .read(accountsProvider.notifier)
                  .updateBalance(account.id, value);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
