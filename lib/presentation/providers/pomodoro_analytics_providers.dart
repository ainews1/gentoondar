import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/presentation/providers/analytics_providers.dart';
import 'package:task_calendar_app/presentation/providers/pomodoro_session_providers.dart';
import 'package:task_calendar_app/presentation/providers/task_providers.dart';

// =============================================================================
// Pomodoro Analytics Data Model
// =============================================================================

/// Aggregated Pomodoro analytics data for a given date range.
class PomodoroAnalyticsData extends Equatable {
  /// Completed work sessions per day (date normalized to midnight)
  final Map<DateTime, int> dailySessions;

  /// Completed work sessions per taskId
  final Map<int, int> taskSessions;

  /// Task names for display (taskId -> name)
  final Map<int, String> taskNames;

  /// Total completed work sessions in the range
  final int totalSessions;

  /// Total focus minutes (sum of actual duration for completed work sessions)
  final int totalFocusMinutes;

  /// Average daily session count across the range
  final double averageDailySessionsCount;

  const PomodoroAnalyticsData({
    required this.dailySessions,
    required this.taskSessions,
    required this.taskNames,
    required this.totalSessions,
    required this.totalFocusMinutes,
    required this.averageDailySessionsCount,
  });

  /// Empty analytics data
  static const empty = PomodoroAnalyticsData(
    dailySessions: {},
    taskSessions: {},
    taskNames: {},
    totalSessions: 0,
    totalFocusMinutes: 0,
    averageDailySessionsCount: 0,
  );

  @override
  List<Object?> get props => [
        dailySessions,
        taskSessions,
        taskNames,
        totalSessions,
        totalFocusMinutes,
        averageDailySessionsCount,
      ];
}

// =============================================================================
// Pomodoro Analytics Provider
// =============================================================================

/// Provides aggregated Pomodoro analytics data for the currently selected
/// analytics range (week/month/quarter). Queries sessions from the repository
/// and enriches with task names from the task repository.
final pomodoroAnalyticsDataProvider =
    FutureProvider<PomodoroAnalyticsData>((ref) async {
  final (startDate, endDate) = ref.watch(analyticsDateRangeProvider);
  final pomodoroRepository = ref.watch(pomodoroRepositoryProvider);
  final taskRepository = ref.watch(taskRepositoryProvider);

  // Query all pomodoro sessions in the date range
  final sessionsResult =
      await pomodoroRepository.getSessionsInDateRange(startDate, endDate);

  return sessionsResult.fold(
    (failure) => PomodoroAnalyticsData.empty,
    (sessions) async {
      // Filter to completed work sessions only
      final workSessions = sessions
          .where((s) => s.sessionType == 'work' && s.isCompleted)
          .toList();

      if (workSessions.isEmpty) {
        return PomodoroAnalyticsData.empty;
      }

      // Calculate daily sessions
      final dailySessions = <DateTime, int>{};
      for (final session in workSessions) {
        final dateKey = DateTime(
          session.startedAt.toLocal().year,
          session.startedAt.toLocal().month,
          session.startedAt.toLocal().day,
        );
        dailySessions[dateKey] = (dailySessions[dateKey] ?? 0) + 1;
      }

      // Calculate per-task sessions
      final taskSessions = <int, int>{};
      for (final session in workSessions) {
        if (session.taskId > 0) {
          taskSessions[session.taskId] =
              (taskSessions[session.taskId] ?? 0) + 1;
        }
      }

      // Fetch task names
      final taskNames = <int, String>{};
      for (final taskId in taskSessions.keys) {
        final taskResult = await taskRepository.getTaskById(taskId);
        taskResult.fold(
          (failure) => taskNames[taskId] = 'Task #$taskId',
          (task) => taskNames[taskId] = task.title,
        );
      }

      // Calculate totals
      final totalSessions = workSessions.length;
      final totalFocusSeconds = workSessions.fold<int>(
        0,
        (sum, s) => sum + s.durationSeconds,
      );
      final totalFocusMinutes = (totalFocusSeconds / 60).round();

      // Calculate average daily sessions
      final daysInRange = endDate.difference(startDate).inDays + 1;
      final averageDailySessionsCount =
          daysInRange > 0 ? totalSessions / daysInRange : 0.0;

      return PomodoroAnalyticsData(
        dailySessions: dailySessions,
        taskSessions: taskSessions,
        taskNames: taskNames,
        totalSessions: totalSessions,
        totalFocusMinutes: totalFocusMinutes,
        averageDailySessionsCount: averageDailySessionsCount,
      );
    },
  );
});
