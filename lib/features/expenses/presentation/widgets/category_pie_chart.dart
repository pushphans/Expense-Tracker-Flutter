import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<String, double> categoryTotals;

  const CategoryPieChart({super.key, required this.categoryTotals});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryTotals.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data for this month')),
      );
    }

    final total = widget.categoryTotals.values.fold(0.0, (a, b) => a + b);
    final sections = <PieChartSectionData>[];
    final entries = widget.categoryTotals.entries.toList();

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final color = Color(
        AppConstants.categoryColors[entry.key] ?? 0xFF757575,
      );
      final isTouched = i == touchedIndex;
      final percentage = (entry.value / total * 100).toStringAsFixed(1);

      sections.add(PieChartSectionData(
        value: entry.value,
        color: color,
        radius: isTouched ? 65 : 55,
        title: isTouched ? '$percentage%' : '',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 45,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: entries.map((entry) {
            final color = Color(
              AppConstants.categoryColors[entry.key] ?? 0xFF757575,
            );
            final icon = AppConstants.categoryIcons[entry.key] ?? '📦';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$icon ${entry.key}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
