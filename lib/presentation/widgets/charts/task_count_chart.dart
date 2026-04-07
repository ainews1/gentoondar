import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/usecases/get_productivity_analytics.dart';

class TaskCountChart extends StatelessWidget {
  final List<DayMetrics> dailyMetrics;
  final AnalyticsRange timeRange;

  const TaskCountChart({
    Key? key,
    required this.dailyMetrics,
    required this.timeRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dailyMetrics.isEmpty) {
      return _buildEmptyChart(context);
    }

    final maxCount = dailyMetrics
        .map((m) => m.taskCount)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, double.infinity);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount.toDouble() + 2,
          minY: 0,
          groupsSpace: 4,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Theme.of(context).colorScheme.surfaceVariant,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final metrics = dailyMetrics[group.x];
                return BarTooltipItem(
                  '${_formatDate(metrics.date)}\n',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '${metrics.taskCount} tasks\n',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '${metrics.completedCount} completed',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < dailyMetrics.length) {
                    return _buildBottomTitle(
                      context, 
                      dailyMetrics[value.toInt()].date,
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxCount > 10 ? 2 : 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: maxCount > 10 ? 2 : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          barGroups: dailyMetrics.asMap().entries.map((entry) {
            final index = entry.key;
            final metrics = entry.value;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: metrics.taskCount.toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                  width: timeRange == AnalyticsRange.week ? 20 : 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  rodStackItems: metrics.completedCount > 0 ? [
                    BarChartRodStackItem(
                      0,
                      metrics.completedCount.toDouble(),
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ] : [],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No data to display',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTitle(BuildContext context, DateTime date) {
    String title;
    switch (timeRange) {
      case AnalyticsRange.week:
        title = DateFormat('E').format(date); // Mon, Tue, etc.
        break;
      case AnalyticsRange.month:
        title = date.day.toString();
        break;
      case AnalyticsRange.quarter:
        title = DateFormat('MMM').format(date); // Jan, Feb, etc.
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    switch (timeRange) {
      case AnalyticsRange.week:
        return DateFormat('MMM d').format(date);
      case AnalyticsRange.month:
        return DateFormat('MMM d').format(date);
      case AnalyticsRange.quarter:
        return DateFormat('MMM d').format(date);
    }
  }
}