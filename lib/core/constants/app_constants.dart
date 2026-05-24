class AppConstants {
  static const String currencySymbol = '₹';
  static const String appName = 'Expense Tracker';

  static const List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Health',
    'Entertainment',
    'Bills',
    'Other',
  ];

  static const Map<String, String> categoryIcons = {
    'Food': '🍔',
    'Transport': '🚗',
    'Shopping': '🛍️',
    'Health': '💊',
    'Entertainment': '🎬',
    'Bills': '📄',
    'Other': '📦',
  };

  static const Map<String, int> categoryColors = {
    'Food': 0xFFE53935,
    'Transport': 0xFF1E88E5,
    'Shopping': 0xFF8E24AA,
    'Health': 0xFF43A047,
    'Entertainment': 0xFFFB8C00,
    'Bills': 0xFF00ACC1,
    'Other': 0xFF757575,
  };
}
