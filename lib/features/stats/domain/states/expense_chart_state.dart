import 'package:flutter/foundation.dart';

@immutable
class ExpenseChartState {
  final Map<int, double> monthlyTotals;
  final bool isLoading;
  final String? error;

  const ExpenseChartState({
    this.monthlyTotals = const {},
    this.isLoading = false,
    this.error,
  });

  ExpenseChartState copyWith({
    Map<int, double>? monthlyTotals,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseChartState(
      monthlyTotals: monthlyTotals ?? this.monthlyTotals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  ExpenseChartState clearError() {
    return ExpenseChartState(
      monthlyTotals: monthlyTotals,
      isLoading: isLoading,
      error: null,
    );
  }
}
