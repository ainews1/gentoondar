import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/usecases/get_productivity_analytics.dart';

class BusyMinutesChart extends StatelessWidget {
  final List<DayMetrics> dailyMetrics;
  final AnalyticsRange timeRange;

  const BusyMinutesChart({
    Key? key,
    required this.dailyMetrics,
    required this.timeRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dailyMetrics.isEmpty) {
      return _buildEmptyChart(context);
    }

    final maxMinutes = dailyMetrics
        .map((m) => m.totalMinutes)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, double.infinity);

    // Round up to nearest hour for cleaner scale
    final maxHours = ((maxMinutes / 60).ceil() + 1).toDouble();
    final maxY = maxHours * 60;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
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
                      text: '${_formatDuration(metrics.totalMinutes)}\n',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '${_formatDuration(metrics.completedMinutes)} done',
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
                interval: 60, // Show every hour
                getTitlesWidget: (value, meta) {
                  final hours = (value / 60).round();
                  return Text(
                    '${hours}h',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 36,
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
            horizontalInterval: 60, // Grid line every hour
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
                  toY: metrics.totalMinutes.toDouble(),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  width: timeRange == AnalyticsRange.week ? 20 : 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  rodStackItems: metrics.completedMinutes > 0 ? [
                    BarChartRodStackItem(
                      0,
                      metrics.completedMinutes.toDouble(),
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
              Icons.schedule,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No time data to display',
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
        title = DateFormat('E').format(date);
        break;
      case AnalyticsRange.month:
        title = date.day.toString();
        break;
      case AnalyticsRange.quarter:
        title = DateFormat('MMM').format(date);
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

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }
}