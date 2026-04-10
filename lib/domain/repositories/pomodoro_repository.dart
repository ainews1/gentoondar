import 'package:dartz/dartz.dart' as dartz;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_session.dart';

/// Abstract repository interface for Pomodoro session data operations.
/// Uses dartz Either for functional error handling, matching TaskRepository pattern.
abstract class PomodoroRepository {
  /// Save a new pomodoro session and return it with assigned ID.
  Future<dartz.Either<Failure, PomodoroSession>> saveSession(
      PomodoroSession session);

  /// Get all sessions for a specific date.
  Future<dartz.Either<Failure, List<PomodoroSession>>> getSessionsByDate(
      DateTime date);

  /// Get all sessions associated with a specific task.
  Future<dartz.Either<Failure, List<PomodoroSession>>> getSessionsByTaskId(
      int taskId);

  /// Get sessions within a date range (inclusive).
  Future<dartz.Either<Failure, List<PomodoroSession>>> getSessionsInDateRange(
      DateTime start, DateTime end);

  /// Get total count of completed work sessions.
  Future<dartz.Either<Failure, int>> getTotalSessionCount();

  /// Get count of completed work sessions for a specific date.
  Future<dartz.Either<Failure, int>> getDailySessionCount(DateTime date);

  /// Get current streak of consecutive days with completed work sessions.
  Future<dartz.Either<Failure, int>> getStreak();
}
