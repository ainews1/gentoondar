import 'package:dartz/dartz.dart' as dartz;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/data/datasources/local/pomodoro_local_datasource.dart';
import 'package:task_calendar_app/data/models/pomodoro_session_model.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_session.dart';
import 'package:task_calendar_app/domain/repositories/pomodoro_repository.dart';

/// Concrete implementation of PomodoroRepository using local SQLite datasource.
/// Wraps datasource calls with dartz Either error handling, matching TaskRepositoryImpl pattern.
class PomodoroRepositoryImpl implements PomodoroRepository {
  final PomodoroLocalDatasource _localDatasource;

  PomodoroRepositoryImpl({
    required PomodoroLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  @override
  Future<dartz.Either<Failure, PomodoroSession>> saveSession(
      PomodoroSession session) async {
    try {
      final sessionMap = PomodoroSessionModel.toMap(session);
      final newId = await _localDatasource.insertSession(sessionMap);

      final savedSession = session.copyWith(id: newId);
      return dartz.Right(savedSession);
    } catch (e) {
      return dartz.Left(DatabaseFailure(
        'Failed to save pomodoro session: ${e.toString()}',
        'SAVE_SESSION_ERROR',
      ));
    }
  }

  @override
  Future<dartz.Either<Failure, List<PomodoroSession>>> getSessionsByDate(
      DateTime date) async {
    try {
      final results = await _localDatasource.getSessionsByDate(date);
      final sessions =
          results.map((map) => PomodoroSessionModel.fromMap(map)).toList();
      return dartz.Right(sessions);
    } catch (e) {
      return dartz.Left(DatabaseFailure(
        'Failed to get sessions by date: ${e.toString()}',
        'GET_SESSIONS_BY_DATE_ERROR',
      ));
    }
  }

  @override
  Future<dartz.Either<Failure, List<PomodoroSession>>> getSessionsByTaskId(
      int taskId) async {
    try {
      final results = await _localDatasource.getSessionsByTaskId(taskId);
      final sessions =
          results.map((map) => PomodoroSessionModel.fromMap(map)).toList();
      return dartz.Right(sessions);
    } catch (e) {
      return dartz.Left(DatabaseFailure(
        'Failed to get sessions by task ID: ${e.toString()}',
        'GET_SESSIONS_BY_TASK_ID_ERROR',
      ));
    }
  }

  @override
  Future<dartz.Either<Failure, List<PomodoroSession>>> getSessionsInDateRange(
      DateTime start, DateTime end) async {
    try {
      final results =
          await _localDatasource.getSessionsInDateRange(start, end);
      final sessions =
          results.map((map) => PomodoroSessionModel.fromMap(map)).toList();
      return dartz.Right(sessions);
    } catch (e) {
      return dartz.Left(DatabaseFailure(
        'Failed to get sessions in date range: ${e.toString()}',
        'GET_SESSIONS_IN_DATE_RANGE_ERROR',
      ));
    }
  }

  @override
  Future<dartz.Either<Failure, int>> getTotalSessionCount() async {
    try {
      final count = await _localDatasource.getTotalSessionCount();
      return dartz.Right(count);
    } catch (e) {
      return dartz.Left(DatabaseFailure(
        'Failed to get total session count: ${e.toString()}',
        'GET_TOTAL_SESSION_COUNT_ERROR',
      ));
    }
  }

  @override
  Future<dartz.Either<Failure, int>> getDailySessionCount(
      DateTime date) async {
    try {
      final count = await _localDatasource.getDailySessionCount(date);
      return dartz.Right(count);
    } catch (e) {
      return dartz.Left(DatabaseFailure(
        'Failed to get daily session count: ${e.toString()}',
        'GET_DAILY_SESSION_COUNT_ERROR',
      ));
    }
  }

  @override
  Future<dartz.Either<Failure, int>> getStreak() async {
    try {
      final streak = await _localDatasource.getStreak();
      return dartz.Right(streak);
    } catch (e) {
      return dartz.Left(DatabaseFailure(
        'Failed to get streak: ${e.toString()}',
        'GET_STREAK_ERROR',
      ));
    }
  }
}
