import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/data/datasources/local/pomodoro_local_datasource.dart';
import 'package:task_calendar_app/data/datasources/local/pomodoro_settings_datasource.dart';
import 'package:task_calendar_app/data/repositories/pomodoro_repository_impl.dart';
import 'package:task_calendar_app/domain/repositories/pomodoro_repository.dart';
import 'package:task_calendar_app/domain/usecases/complete_pomodoro_session.dart';
import 'package:task_calendar_app/domain/usecases/get_pomodoro_sessions.dart';

// =============================================================================
// Data Layer Providers
// =============================================================================

/// Provides PomodoroLocalDatasource instance for SQLite session operations
final pomodoroLocalDatasourceProvider =
    Provider<PomodoroLocalDatasource>((ref) {
  return PomodoroLocalDatasource();
});

/// Provides PomodoroSettingsDatasource instance for SharedPreferences
final pomodoroSettingsDatasourceProvider =
    Provider<PomodoroSettingsDatasource>((ref) {
  return PomodoroSettingsDatasource();
});

/// Provides PomodoroRepository implementation with injected datasources
final pomodoroRepositoryProvider = Provider<PomodoroRepository>((ref) {
  final localDatasource = ref.watch(pomodoroLocalDatasourceProvider);
  return PomodoroRepositoryImpl(localDatasource: localDatasource);
});

// =============================================================================
// Use Case Providers
// =============================================================================

/// Provides CompletePomodoroSession use case
final completePomodoroSessionUseCaseProvider =
    Provider<CompletePomodoroSession>((ref) {
  final repository = ref.watch(pomodoroRepositoryProvider);
  return CompletePomodoroSession(repository);
});

/// Provides GetPomodoroSessions use case
final getPomodoroSessionsUseCaseProvider =
    Provider<GetPomodoroSessions>((ref) {
  final repository = ref.watch(pomodoroRepositoryProvider);
  return GetPomodoroSessions(repository);
});

/// Provides GetPomodoroSessionsByTask use case
final getPomodoroSessionsByTaskUseCaseProvider =
    Provider<GetPomodoroSessionsByTask>((ref) {
  final repository = ref.watch(pomodoroRepositoryProvider);
  return GetPomodoroSessionsByTask(repository);
});

// =============================================================================
// Data Query Providers
// =============================================================================

/// Returns today's completed work session count (for timer panel "Today: X sessions")
final dailyPomodoroCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(pomodoroRepositoryProvider);
  final result = await repository.getDailySessionCount(DateTime.now());

  return result.fold(
    (failure) => 0,
    (count) => count,
  );
});

/// Returns current streak of consecutive days with completed work sessions
final pomodoroStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(pomodoroRepositoryProvider);
  final result = await repository.getStreak();

  return result.fold(
    (failure) => 0,
    (streak) => streak,
  );
});

/// Returns session count for a given taskId (for task badge display)
final taskPomodoroCountProvider =
    FutureProvider.family<int, int>((ref, taskId) async {
  final repository = ref.watch(pomodoroRepositoryProvider);
  final result = await repository.getSessionsByTaskId(taskId);

  return result.fold(
    (failure) => 0,
    (sessions) =>
        sessions.where((s) => s.sessionType == 'work' && s.isCompleted).length,
  );
});

/// Returns total focus minutes today (sum of durationSeconds / 60 for work sessions)
final dailyFocusMinutesProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(pomodoroRepositoryProvider);
  final result = await repository.getSessionsByDate(DateTime.now());

  return result.fold(
    (failure) => 0,
    (sessions) {
      final workSessions =
          sessions.where((s) => s.sessionType == 'work' && s.isCompleted);
      final totalSeconds =
          workSessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
      return (totalSeconds / 60).round();
    },
  );
});
