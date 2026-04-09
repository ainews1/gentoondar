import 'package:dartz/dartz.dart' hide Task;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/domain/repositories/task_repository.dart';

/// Use case for creating a new task.
/// Validates task data and creates the task through the repository.
class CreateTask implements UseCase<Task, CreateTaskParams> {
  final TaskRepository repository;

  CreateTask(this.repository);

  @override
  Future<Either<Failure, Task>> call(CreateTaskParams params) async {
    // Validate task data
    final validation = _validateTask(params.task);
    if (validation != null) {
      return Left(validation);
    }

    // Create the task through repository
    return await repository.createTask(params.task);
  }

  /// Validates task data according to business rules.
  ValidationFailure? _validateTask(Task task) {
    // Validate title
    if (task.title.trim().isEmpty) {
      return const ValidationFailure(
        'Task title cannot be empty',
        'EMPTY_TITLE',
      );
    }

    if (task.title.length > 100) {
      return const ValidationFailure(
        'Task title cannot exceed 100 characters',
        'TITLE_TOO_LONG',
      );
    }

    // Validate description
    if (task.description != null && task.description!.length > 500) {
      return const ValidationFailure(
        'Task description cannot exceed 500 characters',
        'DESCRIPTION_TOO_LONG',
      );
    }

    // Validate duration
    if (task.durationMinutes <= 0) {
      return const ValidationFailure(
        'Task duration must be greater than 0 minutes',
        'INVALID_DURATION',
      );
    }

    if (task.durationMinutes > 480) {
      return const ValidationFailure(
        'Task duration cannot exceed 480 minutes (8 hours)',
        'DURATION_TOO_LONG',
      );
    }

    // Validate start time (must not be null and should be reasonable)
    final now = DateTime.now();
    final oneYearFromNow = now.add(const Duration(days: 365));
    
    if (task.startTime.isBefore(now.subtract(const Duration(days: 365)))) {
      return const ValidationFailure(
        'Task start time cannot be more than a year in the past',
        'START_TIME_TOO_OLD',
      );
    }

    if (task.startTime.isAfter(oneYearFromNow)) {
      return const ValidationFailure(
        'Task start time cannot be more than a year in the future',
        'START_TIME_TOO_FUTURE',
      );
    }

    return null; // No validation errors
  }
}

/// Parameters for CreateTask use case.
class CreateTaskParams {
  final Task task;

  const CreateTaskParams({required this.task});
}