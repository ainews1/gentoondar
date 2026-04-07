import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

class GetProductivityAnalytics implements UseCase<ProductivityData, AnalyticsParams> {
  final TaskRepository repository;

  GetProductivityAnalytics(this.repository);

  @override
  Future<Either<Failure, ProductivityData>> call(AnalyticsParams params) async {
    final result = await repository.getTasksInDateRange(params.startDate, params.endDate);
    
    return result.fold(
      (failure) => Left(failure),
      (tasks) => Right(_calculateProductivityData(tasks, params)),
    );
  }

  ProductivityData _calculateProductivityData(List<Task> tasks, AnalyticsParams params) {
    final dailyMetrics = <DateTime, DayMetrics>{};
    final range = params.endDate.difference(params.startDate).inDays + 1;
    
    // Initialize all days in range with zero values
    for (int i = 0; i < range; i++) {
      final date = params.startDate.add(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      dailyMetrics[dateKey] = DayMetrics(
        date: dateKey,
        taskCount: 0,
        completedCount: 0,
        totalMinutes: 0,
        completedMinutes: 0,
        averageDuration: 0,
      );
    }
    
    // Calculate metrics for each task
    for (final task in tasks) {
      final taskDate = DateTime(
        task.startTime.year,
        task.startTime.month,
        task.startTime.day,
      );
      
      if (dailyMetrics.containsKey(taskDate)) {
        final currentMetrics = dailyMetrics[taskDate]!;
        dailyMetrics[taskDate] = DayMetrics(
          date: taskDate,
          taskCount: currentMetrics.taskCount + 1,
          completedCount: currentMetrics.completedCount + (task.isCompleted ? 1 : 0),
          totalMinutes: currentMetrics.totalMinutes + task.durationMinutes,
          completedMinutes: currentMetrics.completedMinutes + 
                           (task.isCompleted ? task.durationMinutes : 0),
          averageDuration: 0, // Will calculate below
        );
      }
    }
    
    // Calculate average durations and sort by date
    final sortedMetrics = dailyMetrics.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    for (int i = 0; i < sortedMetrics.length; i++) {
      final metrics = sortedMetrics[i];
      final avgDuration = metrics.taskCount > 0 
          ? (metrics.totalMinutes / metrics.taskCount).round()
          : 0;
      
      sortedMetrics[i] = DayMetrics(
        date: metrics.date,
        taskCount: metrics.taskCount,
        completedCount: metrics.completedCount,
        totalMinutes: metrics.totalMinutes,
        completedMinutes: metrics.completedMinutes,
        averageDuration: avgDuration,
      );
    }
    
    // Calculate summary statistics
    final totalTasks = sortedMetrics.fold<int>(0, (sum, m) => sum + m.taskCount);
    final totalCompleted = sortedMetrics.fold<int>(0, (sum, m) => sum + m.completedCount);
    final totalMinutes = sortedMetrics.fold<int>(0, (sum, m) => sum + m.totalMinutes);
    final activeDays = sortedMetrics.where((m) => m.taskCount > 0).length;
    
    final summary = ProductivitySummary(
      totalTasks: totalTasks,
      completedTasks: totalCompleted,
      completionRate: totalTasks > 0 ? (totalCompleted / totalTasks) : 0.0,
      totalMinutes: totalMinutes,
      averageTasksPerDay: activeDays > 0 ? (totalTasks / activeDays) : 0.0,
      averageMinutesPerDay: activeDays > 0 ? (totalMinutes / activeDays) : 0.0,
      mostProductiveDay: _findMostProductiveDay(sortedMetrics),
      busiestDay: _findBusiestDay(sortedMetrics),
    );
    
    return ProductivityData(
      timeRange: params.range,
      startDate: params.startDate,
      endDate: params.endDate,
      dailyMetrics: sortedMetrics,
      summary: summary,
    );
  }

  DateTime? _findMostProductiveDay(List<DayMetrics> metrics) {
    if (metrics.isEmpty) return null;
    
    final mostProductive = metrics.reduce((a, b) => 
        a.completedCount > b.completedCount ? a : b);
    
    return mostProductive.completedCount > 0 ? mostProductive.date : null;
  }

  DateTime? _findBusiestDay(List<DayMetrics> metrics) {
    if (metrics.isEmpty) return null;
    
    final busiest = metrics.reduce((a, b) => 
        a.totalMinutes > b.totalMinutes ? a : b);
    
    return busiest.totalMinutes > 0 ? busiest.date : null;
  }
}

class AnalyticsParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final AnalyticsRange range;

  const AnalyticsParams({
    required this.startDate,
    required this.endDate,
    required this.range,
  });

  @override
  List<Object> get props => [startDate, endDate, range];
}

enum AnalyticsRange { week, month, quarter }

class ProductivityData {
  final AnalyticsRange timeRange;
  final DateTime startDate;
  final DateTime endDate;
  final List<DayMetrics> dailyMetrics;
  final ProductivitySummary summary;

  ProductivityData({
    required this.timeRange,
    required this.startDate,
    required this.endDate,
    required this.dailyMetrics,
    required this.summary,
  });
}

class DayMetrics {
  final DateTime date;
  final int taskCount;
  final int completedCount;
  final int totalMinutes;
  final int completedMinutes;
  final int averageDuration;

  DayMetrics({
    required this.date,
    required this.taskCount,
    required this.completedCount,
    required this.totalMinutes,
    required this.completedMinutes,
    required this.averageDuration,
  });
  
  double get completionRate => taskCount > 0 ? (completedCount / taskCount) : 0.0;
  int get pendingCount => taskCount - completedCount;
  int get pendingMinutes => totalMinutes - completedMinutes;
}

class ProductivitySummary {
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final int totalMinutes;
  final double averageTasksPerDay;
  final double averageMinutesPerDay;
  final DateTime? mostProductiveDay;
  final DateTime? busiestDay;

  ProductivitySummary({
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.totalMinutes,
    required this.averageTasksPerDay,
    required this.averageMinutesPerDay,
    this.mostProductiveDay,
    this.busiestDay,
  });
  
  int get pendingTasks => totalTasks - completedTasks;
  String get totalHours => '${(totalMinutes / 60).toStringAsFixed(1)}h';
  String get averageHoursPerDay => '${(averageMinutesPerDay / 60).toStringAsFixed(1)}h';
}