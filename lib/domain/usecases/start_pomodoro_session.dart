import 'package:dartz/dartz.dart' hide Task;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_session.dart';

/// Use case for starting a new Pomodoro session.
/// Constructs a PomodoroSession with startedAt = now.
/// Does not persist to database — that happens on completion via CompletePomodoroSession.
class StartPomodoroSession
    implements UseCase<PomodoroSession, StartPomodoroSessionParams> {
  StartPomodoroSession();

  @override
  Future<Either<Failure, PomodoroSession>> call(
      StartPomodoroSessionParams params) async {
    // Validate session type
    const validTypes = ['work', 'short_break', 'long_break'];
    if (!validTypes.contains(params.sessionType)) {
      return const Left(ValidationFailure(
        'Session type must be work, short_break, or long_break',
        'INVALID_SESSION_TYPE',
      ));
    }

    if (params.plannedDurationSeconds <= 0) {
      return const Left(ValidationFailure(
        'Planned duration must be greater than 0',
        'INVALID_DURATION',
      ));
    }

    final now = DateTime.now().toUtc();
    final session = PomodoroSession(
      id: 0,
      taskId: params.taskId,
      sessionType: params.sessionType,
      startedAt: now,
      endedAt: now, // Placeholder — will be set on completion
      durationSeconds: 0,
      plannedDurationSeconds: params.plannedDurationSeconds,
      isCompleted: false,
      createdAt: now,
    );

    return Right(session);
  }
}

/// Parameters for StartPomodoroSession use case.
class StartPomodoroSessionParams {
  final int taskId;
  final String sessionType;
  final int plannedDurationSeconds;

  const StartPomodoroSessionParams({
    required this.taskId,
    required this.sessionType,
    required this.plannedDurationSeconds,
  });
}
