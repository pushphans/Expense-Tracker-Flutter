import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../expense_history/domain/notifiers/expense_filter_notifier.dart';
import '../../domain/notifiers/expense_chart_notifier.dart';
import '../../../home/domain/notifiers/monthly_expense_notifier.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  Widget build(BuildContext context) {
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
          // Month selector
          Consumer(
            builder: (context, ref, child) {
              final filterState = ref.watch(expenseFilterNotifierProvider);
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => ref.read(expenseFilterNotifierProvider.notifier).changeMonth(-1),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(filterState.selectedMonth),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => ref.read(expenseFilterNotifierProvider.notifier).changeMonth(1),
                  ),
                ],
              );
            },
          ),
          
          // Total spent card
          Consumer(
            builder: (context, ref, child) {
              final monthlyState = ref.watch(monthlyExpenseNotifierProvider);
              
              if (monthlyState.isLoading) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              
              final total = ref.read(monthlyExpenseNotifierProvider.notifier).total;
              
              return Card(
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
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Category pie chart
          Consumer(
            builder: (context, ref, child) {
              final categoryTotals = ref.read(monthlyExpenseNotifierProvider.notifier).categoryTotals;
              
              return Card(
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
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Category breakdown
          Consumer(
            builder: (context, ref, child) {
              final total = ref.read(monthlyExpenseNotifierProvider.notifier).total;
              final categoryTotals = ref.read(monthlyExpenseNotifierProvider.notifier).categoryTotals;
              
              if (categoryTotals.isEmpty) return const SizedBox.shrink();
              
              return Card(
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
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Monthly bar chart
          Consumer(
            builder: (context, ref, child) {
              final chartState = ref.watch(expenseChartNotifierProvider);
              final filterState = ref.watch(expenseFilterNotifierProvider);
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Overview — ${filterState.selectedMonth.year}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildChartView(chartState, filterState.selectedMonth.year),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartView(state, int year) {
    if (state.isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Text('Error: ${state.error}');
    }

    return MonthlyBarChart(
      monthlyTotals: state.monthlyTotals,
      year: year,
    );
  }
}
