import 'package:dartz/dartz.dart';
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/domain/repositories/task_repository.dart';

/// Use case for filtering tasks by date range.
/// Performs inclusive filtering on both start and end dates,
/// returning results ordered by most recent first (creation date descending).
class FilterTasksByDateRange implements UseCase<List<Task>, FilterTasksByDateRangeParams> {
  final TaskRepository repository;

  FilterTasksByDateRange(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(FilterTasksByDateRangeParams params) async {
    // Handle null dates - if both are null, return all tasks
    if (params.startDate == null && params.endDate == null) {
      return await repository.getAllTasks();
    }

    // Basic validation for date range
    if (params.startDate != null && params.endDate != null) {
      if (params.startDate!.isAfter(params.endDate!)) {
        return const Left(ValidationFailure(
          'Start date cannot be after end date',
          'INVALID_DATE_RANGE',
        ));
      }
    }

    // Validate dates are not too far in the future or past
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 365 * 2)); // 2 years
    final maxPastDate = now.subtract(const Duration(days: 365 * 10)); // 10 years

    if (params.startDate != null && params.startDate!.isAfter(maxFutureDate)) {
      return const Left(ValidationFailure(
        'Start date cannot be more than 2 years in the future',
        'START_DATE_TOO_FUTURE',
      ));
    }

    if (params.endDate != null && params.endDate!.isAfter(maxFutureDate)) {
      return const Left(ValidationFailure(
        'End date cannot be more than 2 years in the future',
        'END_DATE_TOO_FUTURE',
      ));
    }

    if (params.startDate != null && params.startDate!.isBefore(maxPastDate)) {
      return const Left(ValidationFailure(
        'Start date cannot be more than 10 years in the past',
        'START_DATE_TOO_OLD',
      ));
    }

    if (params.endDate != null && params.endDate!.isBefore(maxPastDate)) {
      return const Left(ValidationFailure(
        'End date cannot be more than 10 years in the past',
        'END_DATE_TOO_OLD',
      ));
    }

    // Perform date range filtering through repository
    return await repository.getTasksInDateRange(params.startDate, params.endDate);
  }
}

/// Parameters for FilterTasksByDateRange use case.
/// Date range is inclusive on both ends - tasks that start on startDate or endDate are included.
class FilterTasksByDateRangeParams {
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterTasksByDateRangeParams({
    this.startDate,
    this.endDate,
  });
}