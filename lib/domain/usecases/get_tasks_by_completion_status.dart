import 'package:dartz/dartz.dart' as dartz;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/domain/repositories/task_repository.dart';

/// Enum for filtering tasks by completion status
enum CompletionStatusFilter {
  all,
  completed,
  pending,
}

/// Use case for filtering tasks by completion status.
/// Returns tasks filtered by completion state, ordered by most recent first.
class GetTasksByCompletionStatus implements UseCase<List<Task>, GetTasksByCompletionStatusParams> {
  final TaskRepository repository;

  GetTasksByCompletionStatus(this.repository);

  @override
  Future<dartz.Either<Failure, List<Task>>> call(GetTasksByCompletionStatusParams params) async {
    try {
      switch (params.filter) {
        case CompletionStatusFilter.all:
          // Return all tasks regardless of completion status
          return await repository.getAllTasks();
          
        case CompletionStatusFilter.completed:
          // Return only completed tasks
          return await repository.getTasksByCompletionStatus(true);
          
        case CompletionStatusFilter.pending:
          // Return only pending (not completed) tasks
          return await repository.getTasksByCompletionStatus(false);
      }
    } catch (e) {
      return dartz.Left(DatabaseFailure(
        'Failed to get tasks by completion status: ${e.toString()}',
        'GET_TASKS_BY_COMPLETION_STATUS_ERROR',
      ));
    }
  }
}

/// Parameters for GetTasksByCompletionStatus use case.
class GetTasksByCompletionStatusParams {
  final CompletionStatusFilter filter;

  const GetTasksByCompletionStatusParams({
    required this.filter,
  });

  /// Helper constructors for common filter scenarios
  const GetTasksByCompletionStatusParams.all() : filter = CompletionStatusFilter.all;
  const GetTasksByCompletionStatusParams.completed() : filter = CompletionStatusFilter.completed;
  const GetTasksByCompletionStatusParams.pending() : filter = CompletionStatusFilter.pending;
}