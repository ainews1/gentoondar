import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/analytics_providers.dart';
import '../../providers/pomodoro_analytics_providers.dart';
import '../../../domain/usecases/get_productivity_analytics.dart';

/// Pomodoro analytics charts widget displaying daily focus sessions
/// and per-task breakdown charts. Integrates into the existing Analytics tab.
class PomodoroChartsWidget extends ConsumerWidget {
  const PomodoroChartsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(pomodoroAnalyticsDataProvider);
    final currentRange = ref.watch(analyticsRangeProvider);

    return analyticsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error loading focus analytics: $error',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      data: (data) => _buildContent(context, data, currentRange),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PomodoroAnalyticsData data,
    AnalyticsRange range,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Focus Sessions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),

        // Summary stats row
        _buildSummaryStats(context, data),
        const SizedBox(height: 16),

        // Chart 1: Daily Focus Sessions
        _buildDailySessionsChart(context, data, range),
        const SizedBox(height: 16),

        // Chart 2: Focus by Task
        _buildTaskSessionsChart(context, data),
      ],
    );
  }

  /// Summary stats row: Total sessions, Avg/day, Total focus time
  Widget _buildSummaryStats(BuildContext context, PomodoroAnalyticsData data) {
    final hours = data.totalFocusMinutes ~/ 60;
    final minutes = data.totalFocusMinutes % 60;
    final focusTimeStr =
        hours > 0 ? '${hours}h ${minutes}m focused' : '${minutes}m focused';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        children: [
          _buildStatChip(
            context,
            'Total: ${data.totalSessions} sessions',
            Icons.timer,
          ),
          _buildStatChip(
            context,
            'Avg: ${data.averageDailySessionsCount.toStringAsFixed(1)}/day',
            Icons.show_chart,
          ),
          _buildStatChip(
            context,
            focusTimeStr,
            Icons.access_time_filled,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFE53935)),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  /// Chart 1: Daily Focus Sessions bar chart (vertical)
  Widget _buildDailySessionsChart(
    BuildContext context,
    PomodoroAnalyticsData data,
    AnalyticsRange range,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart, color: Color(0xFFE53935)),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Focus Sessions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            if (data.dailySessions.isEmpty)
              _buildEmptyState(
                context,
                'No focus session data yet. Complete your first Pomodoro to see analytics.',
                Icons.timer_off,
              )
            else
              _buildDailyBarChart(context, data, range),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBarChart(
    BuildContext context,
    PomodoroAnalyticsData data,
    AnalyticsRange range,
  ) {
    // Sort daily sessions by date
    final sortedEntries = data.dailySessions.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxCount = sortedEntries
        .map((e) => e.value)
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
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final entry = sortedEntries[group.x];
                return BarTooltipItem(
                  '${DateFormat('MMM d').format(entry.key)}\n${entry.value} sessions',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < sortedEntries.length) {
                    return _buildBottomTitle(
                        context, sortedEntries[value.toInt()].key, range);
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
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
          barGroups: sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final mapEntry = entry.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: mapEntry.value.toDouble(),
                  color: const Color(0xFFE53935), // Work red
                  width: range == AnalyticsRange.week ? 20 : 12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
              showingTooltipIndicators: mapEntry.value > 0 ? [0] : [],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Chart 2: Focus by Task horizontal bar chart
  Widget _buildTaskSessionsChart(
    BuildContext context,
    PomodoroAnalyticsData data,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.assignment, color: Color(0xFF1976D2)),
                  const SizedBox(width: 8),
                  Text(
                    'Focus by Task',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            if (data.taskSessions.isEmpty)
              _buildEmptyState(
                context,
                'No task-linked focus sessions yet.',
                Icons.assignment_outlined,
              )
            else
              _buildTaskBarChart(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskBarChart(
    BuildContext context,
    PomodoroAnalyticsData data,
  ) {
    // Sort by session count descending, take top 8
    final sortedTasks = data.taskSessions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTasks = sortedTasks.take(8).toList();

    final maxCount = topTasks.first.value.clamp(1, double.infinity);

    return Container(
      height: (topTasks.length * 40.0).clamp(80, 320),
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount.toDouble() + 1,
          minY: 0,
          groupsSpace: 4,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final entry = topTasks[group.x];
                final name =
                    data.taskNames[entry.key] ?? 'Task #${entry.key}';
                return BarTooltipItem(
                  '$name\n${entry.value} sessions',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < topTasks.length) {
                    final taskId = topTasks[value.toInt()].key;
                    final name = data.taskNames[taskId] ?? 'Task #$taskId';
                    final truncated =
                        name.length > 20 ? '${name.substring(0, 17)}...' : name;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        truncated,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
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
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          barGroups: topTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final mapEntry = entry.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: mapEntry.value.toDouble(),
                  color: const Color(0xFF1976D2), // Primary blue
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String message,
    IconData icon,
  ) {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTitle(
    BuildContext context,
    DateTime date,
    AnalyticsRange range,
  ) {
    String title;
    switch (range) {
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
}
