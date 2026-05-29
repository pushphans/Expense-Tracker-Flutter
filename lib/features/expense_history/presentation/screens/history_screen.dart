import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/expense_model.dart';
import '../../domain/notifiers/expense_filter_notifier.dart';
import '../../../expense_form/domain/notifiers/expense_form_notifier.dart';
import '../../domain/notifiers/filtered_expense_notifier.dart';
import '../../../../shared/widgets/expense_list_tile.dart';
import '../../../expense_form/presentation/screens/add_expense_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(expenseFilterNotifierProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => ref.read(expenseFilterNotifierProvider.notifier).setSearchQuery(v),
            ),
          ),
          
          // Category filters
          Consumer(
            builder: (context, ref, child) {
              final filterState = ref.watch(expenseFilterNotifierProvider);
              
              return SizedBox(
                height: 40,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: filterState.selectedCategory == null,
                        onSelected: (_) =>
                            ref.read(expenseFilterNotifierProvider.notifier).clearCategory(),
                      ),
                    ),
                    ...AppConstants.categories.map((cat) {
                      final icon = AppConstants.categoryIcons[cat] ?? '📦';
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text('$icon $cat'),
                          selected: filterState.selectedCategory == cat,
                          onSelected: (_) => ref
                              .read(expenseFilterNotifierProvider.notifier)
                              .setCategory(filterState.selectedCategory == cat ? null : cat),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 4),
          
          // Expense list
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final expenseState = ref.watch(filteredExpenseNotifierProvider);
                return _buildExpenseList(context, expenseState, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, state, ThemeData theme) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            const Text('No expenses found'),
          ],
        ),
      );
    }

    final grouped = _groupByDate(state.expenses);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final group = grouped[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatGroupDate(group.date),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${AppConstants.currencySymbol}${group.total.toStringAsFixed(2)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            ...group.expenses.map((expense) => ExpenseListTile(
                  expense: expense,
                  onTap: () => _openEdit(context, expense),
                  onDelete: () => ref.read(expenseFormNotifierProvider.notifier).deleteExpense(expense.id!),
                )),
          ],
        );
      },
    );
  }

  List<_DateGroup> _groupByDate(List<Expense> expenses) {
    final map = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = DateFormat('yyyy-MM-dd').format(e.date);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map.entries
        .map((entry) => _DateGroup(
              date: DateFormat('yyyy-MM-dd').parse(entry.key),
              expenses: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String _formatGroupDate(DateTime date) {
    final now = DateTime.now();
    if (DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(now)) {
      return 'Today';
    }
    if (DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('EEEE, MMM dd').format(date);
  }

  Future<void> _openEdit(BuildContext context, Expense expense) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: expense)),
    );
  }
}

class _DateGroup {
  final DateTime date;
  final List<Expense> expenses;

  _DateGroup({required this.date, required this.expenses});

  double get total => expenses.fold(0.0, (sum, e) => sum + e.amount);
}
