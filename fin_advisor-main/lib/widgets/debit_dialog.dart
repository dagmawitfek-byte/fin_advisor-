import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/sms_message.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';

class DebitDialog extends ConsumerStatefulWidget {
  final SmsMessage debitMessage;
  final Function(Transaction) onTransactionSaved;

  const DebitDialog({
    required this.debitMessage,
    required this.onTransactionSaved,
    super.key,
  });

  @override
  ConsumerState<DebitDialog> createState() => _DebitDialogState();
}

class _DebitDialogState extends ConsumerState<DebitDialog> {
  late TextEditingController _purposeController;
  String? _selectedCategoryId;

  final List<String> _commonPurposes = [
    'Food & Groceries',
    'Transportation',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Medical',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _purposeController = TextEditingController();
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a purpose')),
      );
      return;
    }

    final amount = widget.debitMessage.extractAmount() ?? 0.0;
    final categories = ref.read(categoriesProvider);
    final expenseCategories = categories.where((c) => !c.isIncome).toList();

    // Use selected category or first available expense category
    String categoryId = _selectedCategoryId ?? (expenseCategories.isNotEmpty ? expenseCategories.first.id : '');

    final transaction = Transaction(
      title: _purposeController.text,
      amount: amount,
      categoryId: categoryId,
      date: DateTime.now(),
      isIncome: false,
      note: 'Auto-imported from bank SMS: ${widget.debitMessage.body}',
    );

    // Save to database
    ref.read(transactionsProvider.notifier).add(transaction);

    widget.onTransactionSaved(transaction);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debit of ETB ${amount.toStringAsFixed(2)} saved as ${_purposeController.text}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final expenseCategories = categories.where((c) => !c.isIncome).toList();
    final amount = widget.debitMessage.extractAmount();

    // Set default category on first build
    if (_selectedCategoryId == null && expenseCategories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCategoryId = expenseCategories.first.id;
          });
        }
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Debit Transaction',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Amount
              if (amount != null)
                Text(
                  'ETB ${amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),

              // Question
              Text(
                'What was this payment for?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Quick purpose selection
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonPurposes.map((purpose) {
                  return ChoiceChip(
                    label: Text(purpose, style: const TextStyle(fontSize: 12)),
                    selected: _purposeController.text == purpose,
                    onSelected: (selected) {
                      setState(() {
                        _purposeController.text = purpose;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Category selection
              if (expenseCategories.isNotEmpty) ...[
                Text(
                  'Select Category',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: expenseCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = expenseCategories[index];
                      final isSelected = _selectedCategoryId == category.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? category.color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                            border: Border.all(
                              color: isSelected ? category.color : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(category.icon, color: category.color, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                category.name,
                                style: TextStyle(
                                  color: isSelected ? category.color : Colors.grey,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Custom purpose input
              TextField(
                controller: _purposeController,
                decoration: InputDecoration(
                  hintText: 'Enter custom purpose or select from above',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.edit),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
