import 'package:dartz/dartz.dart';
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/domain/entities/task.dart';

/// Repository interface for task data operations.
/// Abstracts data source details from business logic.
abstract class TaskRepository {
  /// Create a new task and return it with assigned ID.
  /// Returns Either<Failure, Task> for functional error handling.
  Future<Either<Failure, Task>> createTask(Task task);

  /// Update an existing task.
  /// Returns Either<Failure, Task> with updated task data.
  Future<Either<Failure, Task>> updateTask(Task task);

  /// Delete a task by ID.
  /// Returns Either<Failure, void> indicating success or failure.
  Future<Either<Failure, void>> deleteTask(int id);

  /// Get a single task by its ID.
  /// Returns Either<Failure, Task> or NotFoundFailure if task doesn't exist.
  Future<Either<Failure, Task>> getTaskById(int id);

  /// Get all tasks for a specific date.
  /// Returns Either<Failure, List<Task>> with tasks that start on the given date.
  Future<Either<Failure, List<Task>>> getTasksByDate(DateTime date);

  /// Get all tasks in the database.
  /// Returns Either<Failure, List<Task>> with all available tasks.
  Future<Either<Failure, List<Task>>> getAllTasks();

  /// Search tasks by title or description text.
  /// Performs case-insensitive search and returns results ordered by most recent first.
  /// Returns Either<Failure, List<Task>> with matching tasks.
  Future<Either<Failure, List<Task>>> searchTasks(String searchTerm);

  /// Get tasks within a date range (inclusive on both ends).
  /// If startDate is null, no lower bound. If endDate is null, no upper bound.
  /// Returns Either<Failure, List<Task>> with tasks in the date range.
  Future<Either<Failure, List<Task>>> getTasksInDateRange(DateTime? startDate, DateTime? endDate);

  /// Get tasks filtered by completion status.
  /// Returns Either<Failure, List<Task>> with tasks matching the completion status.
  Future<Either<Failure, List<Task>>> getTasksByCompletionStatus(bool isCompleted);
}