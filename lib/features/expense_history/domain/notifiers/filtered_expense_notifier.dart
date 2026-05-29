import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/repositories/expense_repository.dart';
import 'expense_filter_notifier.dart';
import '../states/expense_list_state.dart';

// Provider
final filteredExpenseNotifierProvider =
    NotifierProvider<FilteredExpenseNotifier, ExpenseListState>(
  FilteredExpenseNotifier.new,
);

// Notifier
class FilteredExpenseNotifier extends Notifier<ExpenseListState> {
  late ExpenseRepository _repository;

  @override
  ExpenseListState build() {
    _repository = ExpenseRepository();
    Future.microtask(() => loadExpenses());
    return const ExpenseListState();
  }

  Future<void> loadExpenses() async {
    final filter = ref.read(expenseFilterNotifierProvider);
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      var expenses = await _repository.searchExpenses(filter.searchQuery);
      
      if (filter.selectedCategory != null) {
        expenses = expenses
            .where((e) => e.category == filter.selectedCategory)
            .toList();
      }
      
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
