import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/providers/expense_providers.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final categoryTotals = ref.watch(categoryTotalsProvider);
    final monthlyTotalsAsync = ref.watch(monthlyTotalsChartProvider);
    final total = ref.watch(monthlyTotalProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(ref, -1),
              ),
              Text(
                DateFormat('MMMM yyyy').format(month),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(ref, 1),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Spent', style: theme.textTheme.titleSmall),
                  Text(
                    '${AppConstants.currencySymbol}${total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending by Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CategoryPieChart(categoryTotals: categoryTotals),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (categoryTotals.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...() {
                      final sorted = categoryTotals.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      return sorted.map((entry) {
                        final color = Color(
                          AppConstants.categoryColors[entry.key] ?? 0xFF757575,
                        );
                        final icon = AppConstants.categoryIcons[entry.key] ?? '📦';
                        final pct = total > 0
                            ? (entry.value / total * 100).toStringAsFixed(1)
                            : '0';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(icon),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(entry.key)),
                                  Text(
                                    '${AppConstants.currencySymbol}${entry.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$pct%',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: total > 0 ? entry.value / total : 0,
                                  backgroundColor: color.withValues(alpha: 0.15),
                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    }(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Overview — ${month.year}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  monthlyTotalsAsync.when(
                    loading: () => const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Error: $e'),
                    data: (totals) => MonthlyBarChart(
                      monthlyTotals: totals,
                      year: month.year,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeMonth(WidgetRef ref, int delta) {
    final current = ref.read(selectedMonthProvider);
    ref.read(selectedMonthProvider.notifier).state = DateTime(
      current.year,
      current.month + delta,
    );
  }
}
