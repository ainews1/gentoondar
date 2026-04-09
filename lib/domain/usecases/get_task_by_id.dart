import 'package:dartz/dartz.dart' hide Task;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/domain/repositories/task_repository.dart';

/// Use case for retrieving a task by its ID.
/// Validates the ID and fetches the task through the repository.
class GetTaskById implements UseCase<Task, GetTaskByIdParams> {
  final TaskRepository repository;

  GetTaskById(this.repository);

  @override
  Future<Either<Failure, Task>> call(GetTaskByIdParams params) async {
    // Validate task ID
    if (params.id <= 0) {
      return const Left(ValidationFailure(
        'Task ID must be greater than 0',
        'INVALID_TASK_ID',
      ));
    }

    // Get the task through repository
    return await repository.getTaskById(params.id);
  }
}

/// Parameters for GetTaskById use case.
class GetTaskByIdParams {
  final int id;

  const GetTaskByIdParams({required this.id});
}