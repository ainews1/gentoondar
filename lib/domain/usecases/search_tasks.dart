import 'package:dartz/dartz.dart';
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/domain/repositories/task_repository.dart';

/// Use case for searching tasks by title or description text.
/// Performs case-insensitive search across task titles and descriptions,
/// returning results ordered by most recent first (creation date descending).
class SearchTasks implements UseCase<List<Task>, SearchTasksParams> {
  final TaskRepository repository;

  SearchTasks(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(SearchTasksParams params) async {
    // Validate search term
    if (params.searchTerm.trim().isEmpty) {
      return const Right([]); // Return empty list for empty search term
    }

    // Basic validation for search term length
    if (params.searchTerm.trim().length > 255) {
      return const Left(ValidationFailure(
        'Search term cannot exceed 255 characters',
        'SEARCH_TERM_TOO_LONG',
      ));
    }

    // Perform search through repository
    return await repository.searchTasks(params.searchTerm.trim());
  }
}

/// Parameters for SearchTasks use case.
class SearchTasksParams {
  final String searchTerm;

  const SearchTasksParams({required this.searchTerm});
}