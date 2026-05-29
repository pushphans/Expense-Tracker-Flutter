import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/expense_model.dart';
import '../../../../shared/repositories/expense_repository.dart';
import '../../../stats/domain/notifiers/expense_chart_notifier.dart';
import '../../../expense_history/domain/notifiers/expense_filter_notifier.dart';
import '../../../expense_history/domain/notifiers/filtered_expense_notifier.dart';
import '../../../home/domain/notifiers/monthly_expense_notifier.dart';
import '../states/expense_form_state.dart';

// Provider
final expenseFormNotifierProvider =
    NotifierProvider<ExpenseFormNotifier, ExpenseFormState>(
  ExpenseFormNotifier.new,
);

// Notifier
class ExpenseFormNotifier extends Notifier<ExpenseFormState> {
  late ExpenseRepository _repository;

  @override
  ExpenseFormState build() {
    _repository = ExpenseRepository();
    return const ExpenseFormState();
  }

  Future<bool> addExpense(Expense expense) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      await _repository.addExpense(expense);
      state = state.copyWith(isSaving: false);
      
      _refreshAllData();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      await _repository.updateExpense(expense);
      state = state.copyWith(isSaving: false);
      
      _refreshAllData();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    state = state.copyWith(isDeleting: true, error: null);

    try {
      await _repository.deleteExpense(id);
      state = state.copyWith(isDeleting: false);
      
      _refreshAllData();
      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: e.toString());
      return false;
    }
  }

  void _refreshAllData() {
    ref.read(monthlyExpenseNotifierProvider.notifier).loadExpenses();
    ref.read(filteredExpenseNotifierProvider.notifier).loadExpenses();
    
    final year = ref.read(expenseFilterNotifierProvider).selectedMonth.year;
    ref.read(expenseChartNotifierProvider.notifier).loadChart(year);
  }
}
