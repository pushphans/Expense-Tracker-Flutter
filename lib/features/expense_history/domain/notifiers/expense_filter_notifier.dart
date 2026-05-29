import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/expense_filter_state.dart';

// Provider
final expenseFilterNotifierProvider =
    NotifierProvider<ExpenseFilterNotifier, ExpenseFilterState>(
  ExpenseFilterNotifier.new,
);

// Notifier
class ExpenseFilterNotifier extends Notifier<ExpenseFilterState> {
  @override
  ExpenseFilterState build() {
    return ExpenseFilterState();
  }

  void selectMonth(DateTime month) {
    state = state.copyWith(selectedMonth: DateTime(month.year, month.month));
  }

  void changeMonth(int delta) {
    final current = state.selectedMonth;
    selectMonth(DateTime(current.year, current.month + delta));
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void clearCategory() {
    state = state.clearCategory();
  }
}
