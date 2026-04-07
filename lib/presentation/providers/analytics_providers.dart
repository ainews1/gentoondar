import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_productivity_analytics.dart';
import 'task_providers.dart';

// Current analytics time range
final analyticsRangeProvider = StateProvider<AnalyticsRange>((ref) => AnalyticsRange.month);

// Use case provider
final getProductivityAnalyticsProvider = Provider<GetProductivityAnalytics>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetProductivityAnalytics(repository);
});

// Date range calculation based on selected range
final analyticsDateRangeProvider = Provider<(DateTime, DateTime)>((ref) {
  final range = ref.watch(analyticsRangeProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  switch (range) {
    case AnalyticsRange.week:
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      return (weekStart, weekEnd);
      
    case AnalyticsRange.month:
      final monthStart = DateTime(today.year, today.month, 1);
      final monthEnd = DateTime(today.year, today.month + 1, 0);
      return (monthStart, monthEnd);
      
    case AnalyticsRange.quarter:
      final quarterMonth = ((today.month - 1) ~/ 3) * 3 + 1;
      final quarterStart = DateTime(today.year, quarterMonth, 1);
      final quarterEnd = DateTime(today.year, quarterMonth + 3, 0);
      return (quarterStart, quarterEnd);
  }
});

// Productivity data provider
final productivityDataProvider = FutureProvider<ProductivityData>((ref) async {
  final range = ref.watch(analyticsRangeProvider);
  final (startDate, endDate) = ref.watch(analyticsDateRangeProvider);
  final getAnalytics = ref.watch(getProductivityAnalyticsProvider);
  
  final result = await getAnalytics(AnalyticsParams(
    startDate: startDate,
    endDate: endDate,
    range: range,
  ));
  
  return result.fold(
    (failure) => throw Exception('Failed to load productivity analytics'),
    (data) => data,
  );
});

// Range title provider
final analyticsRangeTitleProvider = Provider<String>((ref) {
  final range = ref.watch(analyticsRangeProvider);
  final (startDate, endDate) = ref.watch(analyticsDateRangeProvider);
  
  switch (range) {
    case AnalyticsRange.week:
      return 'This Week';
    case AnalyticsRange.month:
      return _getMonthName(startDate.month);
    case AnalyticsRange.quarter:
      return 'Q${((startDate.month - 1) ~/ 3) + 1} ${startDate.year}';
  }
});

String _getMonthName(int month) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[month - 1];
}