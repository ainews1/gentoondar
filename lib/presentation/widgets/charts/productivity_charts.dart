import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/usecases/get_productivity_analytics.dart';
import '../../providers/analytics_providers.dart';
import '../common/responsive_layout.dart';
import 'task_count_chart.dart';
import 'busy_minutes_chart.dart';

class ProductivityChartsWidget extends ConsumerWidget {
  const ProductivityChartsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productivityDataAsync = ref.watch(productivityDataProvider);
    final currentRange = ref.watch(analyticsRangeProvider);
    final rangeTitle = ref.watch(analyticsRangeTitleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Range selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productivity Analytics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                rangeTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildRangeSelector(context, ref, currentRange),
            ],
          ),
        ),
        
        const Divider(),
        
        // Charts content
        Expanded(
          child: productivityDataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading analytics',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            data: (productivityData) => ResponsiveLayout(
              child: _buildMobileLayout(context, productivityData),
              mediumChild: _buildTabletLayout(context, productivityData),
              largeChild: _buildDesktopLayout(context, productivityData),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSelector(BuildContext context, WidgetRef ref, AnalyticsRange currentRange) {
    return Row(
      children: AnalyticsRange.values.map((range) {
        final isSelected = range == currentRange;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(_getRangeLabel(range)),
            selected: isSelected,
            onSelected: (_) {
              ref.read(analyticsRangeProvider.notifier).state = range;
            },
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ProductivityData data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSummaryCards(context, data.summary),
          const SizedBox(height: 16),
          _buildTaskCountSection(context, data),
          const SizedBox(height: 16),
          _buildBusyMinutesSection(context, data),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, ProductivityData data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSummaryCards(context, data.summary),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTaskCountSection(context, data)),
              const SizedBox(width: 16),
              Expanded(child: _buildBusyMinutesSection(context, data)),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ProductivityData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildSummaryCards(context, data.summary),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildTaskCountSection(context, data)),
                const SizedBox(width: 20),
                Expanded(child: _buildBusyMinutesSection(context, data)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, ProductivitySummary summary) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildSummaryCard(
          context,
          'Total Tasks',
          summary.totalTasks.toString(),
          Icons.assignment,
          Theme.of(context).colorScheme.primary,
        ),
        _buildSummaryCard(
          context,
          'Completed',
          '${summary.completedTasks}/${summary.totalTasks}',
          Icons.check_circle,
          Theme.of(context).colorScheme.secondary,
        ),
        _buildSummaryCard(
          context,
          'Total Time',
          summary.totalHours,
          Icons.schedule,
          Theme.of(context).colorScheme.tertiary,
        ),
        _buildSummaryCard(
          context,
          'Completion Rate',
          '${(summary.completionRate * 100).toInt()}%',
          Icons.trending_up,
          summary.completionRate > 0.7 
              ? Colors.green 
              : summary.completionRate > 0.5 
                  ? Colors.orange 
                  : Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCountSection(BuildContext context, ProductivityData data) {
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
                  Icon(
                    Icons.bar_chart,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Task Count',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            TaskCountChart(
              dailyMetrics: data.dailyMetrics,
              timeRange: data.timeRange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusyMinutesSection(BuildContext context, ProductivityData data) {
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
                  Icon(
                    Icons.schedule,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Busy Minutes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            BusyMinutesChart(
              dailyMetrics: data.dailyMetrics,
              timeRange: data.timeRange,
            ),
          ],
        ),
      ),
    );
  }

  String _getRangeLabel(AnalyticsRange range) {
    switch (range) {
      case AnalyticsRange.week:
        return 'Week';
      case AnalyticsRange.month:
        return 'Month';
      case AnalyticsRange.quarter:
        return 'Quarter';
    }
  }
}