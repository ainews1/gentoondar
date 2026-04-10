import 'package:dartz/dartz.dart' hide Task;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_session.dart';
import 'package:task_calendar_app/domain/repositories/pomodoro_repository.dart';

/// Use case for completing a Pomodoro session.
/// Sets endedAt, calculates durationSeconds, and persists via repository.
class CompletePomodoroSession
    implements UseCase<PomodoroSession, CompletePomodoroSessionParams> {
  final PomodoroRepository repository;

  CompletePomodoroSession(this.repository);

  @override
  Future<Either<Failure, PomodoroSession>> call(
      CompletePomodoroSessionParams params) async {
    final now = DateTime.now().toUtc();
    final endedAt = params.endedAt ?? now;
    final durationSeconds =
        endedAt.difference(params.session.startedAt).inSeconds;

    final completedSession = params.session.copyWith(
      endedAt: endedAt,
      durationSeconds: durationSeconds > 0 ? durationSeconds : 0,
      isCompleted: params.isCompleted,
    );

    return await repository.saveSession(completedSession);
  }
}

/// Parameters for CompletePomodoroSession use case.
class CompletePomodoroSessionParams {
  final PomodoroSession session;
  final bool isCompleted;
  final DateTime? endedAt;

  const CompletePomodoroSessionParams({
    required this.session,
    required this.isCompleted,
    this.endedAt,
  });
}
