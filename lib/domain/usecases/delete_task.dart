import 'package:dartz/dartz.dart' hide Task;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/domain/repositories/task_repository.dart';

/// Use case for deleting a task by ID.
/// Validates the ID and deletes the task through the repository.
class DeleteTask implements UseCase<void, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTask(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    // Validate task ID
    if (params.id <= 0) {
      return const Left(ValidationFailure(
        'Task ID must be greater than 0',
        'INVALID_TASK_ID',
      ));
    }

    // Delete the task through repository
    return await repository.deleteTask(params.id);
  }
}

/// Parameters for DeleteTask use case.
class DeleteTaskParams {
  final int id;

  const DeleteTaskParams({required this.id});
}