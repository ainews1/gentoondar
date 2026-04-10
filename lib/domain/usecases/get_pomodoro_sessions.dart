import 'package:dartz/dartz.dart' hide Task;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_session.dart';
import 'package:task_calendar_app/domain/repositories/pomodoro_repository.dart';

/// Use case for retrieving Pomodoro sessions by date.
class GetPomodoroSessions
    implements UseCase<List<PomodoroSession>, GetPomodoroSessionsParams> {
  final PomodoroRepository repository;

  GetPomodoroSessions(this.repository);

  @override
  Future<Either<Failure, List<PomodoroSession>>> call(
      GetPomodoroSessionsParams params) async {
    return await repository.getSessionsByDate(params.date);
  }
}

/// Parameters for GetPomodoroSessions use case.
class GetPomodoroSessionsParams {
  final DateTime date;

  const GetPomodoroSessionsParams({required this.date});
}

/// Use case for retrieving Pomodoro sessions by task ID.
class GetPomodoroSessionsByTask
    implements UseCase<List<PomodoroSession>, GetPomodoroSessionsByTaskParams> {
  final PomodoroRepository repository;

  GetPomodoroSessionsByTask(this.repository);

  @override
  Future<Either<Failure, List<PomodoroSession>>> call(
      GetPomodoroSessionsByTaskParams params) async {
    return await repository.getSessionsByTaskId(params.taskId);
  }
}

/// Parameters for GetPomodoroSessionsByTask use case.
class GetPomodoroSessionsByTaskParams {
  final int taskId;

  const GetPomodoroSessionsByTaskParams({required this.taskId});
}
