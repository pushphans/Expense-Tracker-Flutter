import 'package:flutter/foundation.dart';

import '../../../../shared/models/expense_model.dart';

@immutable
class ExpenseListState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;

  const ExpenseListState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  ExpenseListState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseListState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  ExpenseListState clearError() {
    return ExpenseListState(
      expenses: expenses,
      isLoading: isLoading,
      error: null,
    );
  }
}
