import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';

final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError('Database must be overridden in ProviderScope');
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(databaseProvider));
});

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final allExpensesProvider = FutureProvider<List<Expense>>((ref) {
  return ref.watch(expenseRepositoryProvider).getAll();
});

final monthlyExpensesProvider = FutureProvider<List<Expense>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(expenseRepositoryProvider).getByMonth(month.year, month.month);
});

final monthlyTotalProvider = Provider<double>((ref) {
  final expenses = ref.watch(monthlyExpensesProvider).valueOrNull ?? [];
  return expenses.fold(0.0, (sum, e) => sum + e.amount);
});

final categoryTotalsProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(monthlyExpensesProvider).valueOrNull ?? [];
  final map = <String, double>{};
  for (final e in expenses) {
    map[e.category] = (map[e.category] ?? 0) + e.amount;
  }
  return map;
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCategoryProvider = StateProvider<String?>((ref) => null);

final filteredExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(filteredCategoryProvider);
  final repo = ref.watch(expenseRepositoryProvider);

  var results = await repo.searchExpenses(query);
  if (category != null) {
    results = results.where((e) => e.category == category).toList();
  }
  return results;
});

final monthlyTotalsChartProvider = FutureProvider<Map<int, double>>((ref) {
  final year = ref.watch(selectedMonthProvider).year;
  return ref.watch(expenseRepositoryProvider).getMonthlyTotals(year);
});
