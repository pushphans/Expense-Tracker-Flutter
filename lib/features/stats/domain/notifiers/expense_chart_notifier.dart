import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/repositories/expense_repository.dart';
import '../../../expense_history/domain/notifiers/expense_filter_notifier.dart';
import '../states/expense_chart_state.dart';

// Provider
final expenseChartNotifierProvider =
    NotifierProvider<ExpenseChartNotifier, ExpenseChartState>(
  ExpenseChartNotifier.new,
);

// Notifier
class ExpenseChartNotifier extends Notifier<ExpenseChartState> {
  late ExpenseRepository _repository;

  @override
  ExpenseChartState build() {
    _repository = ExpenseRepository();
    
    // Watch filter changes to reload chart when year changes
    final selectedYear = ref.watch(expenseFilterNotifierProvider).selectedMonth.year;
    
    Future.microtask(() => loadChart(selectedYear));
    return const ExpenseChartState();
  }

  Future<void> loadChart(int year) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final totals = await _repository.getMonthlyTotals(year);
      state = state.copyWith(monthlyTotals: totals, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
