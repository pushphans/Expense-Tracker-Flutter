import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/expense_model.dart';
import '../../domain/providers/expense_providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _saving = false;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _amountController.text = widget.expense!.amount.toStringAsFixed(2);
      _noteController.text = widget.expense!.note ?? '';
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
    } else {
      _selectedCategory = AppConstants.categories.first;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '${AppConstants.currencySymbol} ',
                hintText: '0.00',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: !isEditing,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Enter an amount';
                }
                final parsed = double.tryParse(v);
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Category',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.categories.map((cat) {
                final selected = cat == _selectedCategory;
                final color = Color(
                  AppConstants.categoryColors[cat] ?? 0xFF757575,
                );
                final icon = AppConstants.categoryIcons[cat] ?? '📦';
                return ChoiceChip(
                  label: Text('$icon $cat'),
                  selected: selected,
                  selectedColor: color.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: selected ? color : Colors.transparent,
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'What was this for?',
              ),
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Date'),
              subtitle: Text(
                DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(expenseRepositoryProvider);

    final amount = double.parse(_amountController.text);
    final note = _noteController.text.isEmpty ? null : _noteController.text;

    final expense = isEditing
        ? widget.expense!.copyWith(
            amount: amount,
            category: _selectedCategory,
            note: note,
            date: _selectedDate,
          )
        : Expense(
            amount: amount,
            category: _selectedCategory,
            note: note,
            date: _selectedDate,
          );

    if (isEditing) {
      await repo.updateExpense(expense);
    } else {
      await repo.addExpense(expense);
    }

    _invalidateAll();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(expenseRepositoryProvider)
          .deleteExpense(widget.expense!.id!);
      _invalidateAll();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _invalidateAll() {
    ref.invalidate(monthlyExpensesProvider);
    ref.invalidate(allExpensesProvider);
    ref.invalidate(filteredExpensesProvider);
    ref.invalidate(monthlyTotalsChartProvider);
  }
}
