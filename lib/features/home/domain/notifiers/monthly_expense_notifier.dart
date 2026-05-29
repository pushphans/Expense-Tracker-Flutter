import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/repositories/expense_repository.dart';
import '../../../expense_history/domain/notifiers/expense_filter_notifier.dart';
import '../states/monthly_summary_state.dart';

// Provider
final monthlyExpenseNotifierProvider =
    NotifierProvider<MonthlyExpenseNotifier, ExpenseListState>(
  MonthlyExpenseNotifier.new,
);

// Notifier
class MonthlyExpenseNotifier extends Notifier<ExpenseListState> {
  late ExpenseRepository _repository;

  @override
  ExpenseListState build() {
    _repository = ExpenseRepository();
    
    // Watch selected month to reload when it changes
    final selectedMonth = ref.watch(expenseFilterNotifierProvider).selectedMonth;
    
    Future.microtask(() => loadExpenses(selectedMonth));
    return const ExpenseListState();
  }

  Future<void> loadExpenses([DateTime? month]) async {
    final filterMonth = month ?? ref.read(expenseFilterNotifierProvider).selectedMonth;
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      final expenses = await _repository.getByMonth(
        filterMonth.year,
        filterMonth.month,
      );
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  double get total => state.expenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (final e in state.expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}
