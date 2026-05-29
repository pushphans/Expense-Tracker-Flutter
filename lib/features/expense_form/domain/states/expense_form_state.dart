import 'package:flutter/foundation.dart';

@immutable
class ExpenseFormState {
  final bool isSaving;
  final bool isDeleting;
  final String? error;

  const ExpenseFormState({
    this.isSaving = false,
    this.isDeleting = false,
    this.error,
  });

  ExpenseFormState copyWith({
    bool? isSaving,
    bool? isDeleting,
    String? error,
  }) {
    return ExpenseFormState(
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error ?? this.error,
    );
  }

  ExpenseFormState clearError() {
    return ExpenseFormState(
      isSaving: isSaving,
      isDeleting: isDeleting,
      error: null,
    );
  }
}
