import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';

class MonthlyBarChart extends StatelessWidget {
  final Map<int, double> monthlyTotals;
  final int year;

  const MonthlyBarChart({
    super.key,
    required this.monthlyTotals,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = monthlyTotals.values.isEmpty
        ? 1000.0
        : monthlyTotals.values.reduce((a, b) => a > b ? a : b) * 1.2;

    final barGroups = List.generate(12, (index) {
      final month = index + 1;
      final value = monthlyTotals[month] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: theme.colorScheme.primary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    });

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxValue,
          barGroups: barGroups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${AppConstants.currencySymbol}${_formatAmount(value)}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = [
                    'J', 'F', 'M', 'A', 'M', 'J',
                    'J', 'A', 'S', 'O', 'N', 'D'
                  ];
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(fontSize: 11),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final month = groupIndex + 1;
                final monthName = DateFormat('MMM').format(DateTime(year, month));
                return BarTooltipItem(
                  '$monthName\n${AppConstants.currencySymbol}${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}
