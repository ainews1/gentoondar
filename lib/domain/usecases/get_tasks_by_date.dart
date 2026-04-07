import 'package:dartz/dartz.dart';
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/domain/repositories/task_repository.dart';

/// Use case for retrieving all tasks for a specific date.
/// Validates the date and fetches tasks through the repository.
class GetTasksByDate implements UseCase<List<Task>, GetTasksByDateParams> {
  final TaskRepository repository;

  GetTasksByDate(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(GetTasksByDateParams params) async {
    // Validate date (basic sanity check)
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 365 * 2)); // 2 years
    final maxPastDate = now.subtract(const Duration(days: 365 * 5)); // 5 years
    
    if (params.date.isAfter(maxFutureDate)) {
      return const Left(ValidationFailure(
        'Date cannot be more than 2 years in the future',
        'DATE_TOO_FUTURE',
      ));
    }

    if (params.date.isBefore(maxPastDate)) {
      return const Left(ValidationFailure(
        'Date cannot be more than 5 years in the past',
        'DATE_TOO_OLD',
      ));
    }

    // Get tasks for the date through repository
    return await repository.getTasksByDate(params.date);
  }
}

/// Parameters for GetTasksByDate use case.
class GetTasksByDateParams {
  final DateTime date;

  const GetTasksByDateParams({required this.date});
}