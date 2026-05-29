import 'package:flutter/foundation.dart';

@immutable
class ExpenseFilterState {
  final DateTime selectedMonth;
  final String searchQuery;
  final String? selectedCategory;

  ExpenseFilterState({
    DateTime? selectedMonth,
    this.searchQuery = '',
    this.selectedCategory,
  }) : selectedMonth = selectedMonth ?? _getDefaultMonth();

  static DateTime _getDefaultMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  ExpenseFilterState copyWith({
    DateTime? selectedMonth,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ExpenseFilterState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  ExpenseFilterState clearCategory() {
    return ExpenseFilterState(
      selectedMonth: selectedMonth,
      searchQuery: searchQuery,
      selectedCategory: null,
    );
  }
}
