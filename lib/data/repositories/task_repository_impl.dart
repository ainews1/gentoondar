import 'package:dartz/dartz.dart';
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/domain/repositories/task_repository.dart';
import 'package:task_calendar_app/data/datasources/local/task_local_datasource.dart';
import 'package:task_calendar_app/data/models/task_model.dart';

/// Concrete implementation of TaskRepository using local SQLite data source.
/// Handles data transformation between Task entities and TaskModel objects.
/// Provides error handling by converting exceptions to appropriate Failure types.
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;

  TaskRepositoryImpl({
    required TaskLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final newId = await _localDataSource.insertTask(taskModel);
      
      // Create a new task with the assigned ID and updated timestamp
      final newTask = task.copyWith(
        id: newId,
        updatedAt: DateTime.now().toUtc(),
      );
      
      return Right(newTask);
    } catch (e) {
      return Left(DatabaseFailure(
        'Failed to create task: ${e.toString()}',
        'CREATE_TASK_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      // Update the task's updated timestamp
      final updatedTask = task.copyWith(
        updatedAt: DateTime.now().toUtc(),
      );
      
      final taskModel = TaskModel.fromEntity(updatedTask);
      final rowsAffected = await _localDataSource.updateTask(taskModel);
      
      if (rowsAffected == 0) {
        return Left(NotFoundFailure(
          'Task with ID ${task.id} not found',
          'TASK_NOT_FOUND',
        ));
      }
      
      return Right(updatedTask);
    } catch (e) {
      // Check if it's a not found error based on error message
      if (e.toString().contains('Task not found')) {
        return Left(NotFoundFailure(
          'Task with ID ${task.id} not found',
          'TASK_NOT_FOUND',
        ));
      }
      
      return Left(DatabaseFailure(
        'Failed to update task: ${e.toString()}',
        'UPDATE_TASK_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(int id) async {
    try {
      final rowsAffected = await _localDataSource.deleteTask(id);
      
      if (rowsAffected == 0) {
        return Left(NotFoundFailure(
          'Task with ID $id not found',
          'TASK_NOT_FOUND',
        ));
      }
      
      return const Right(null);
    } catch (e) {
      // Check if it's a not found error based on error message
      if (e.toString().contains('Task not found')) {
        return Left(NotFoundFailure(
          'Task with ID $id not found',
          'TASK_NOT_FOUND',
        ));
      }
      
      return Left(DatabaseFailure(
        'Failed to delete task: ${e.toString()}',
        'DELETE_TASK_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(int id) async {
    try {
      final taskModel = await _localDataSource.getTaskById(id);
      
      if (taskModel == null) {
        return Left(NotFoundFailure(
          'Task with ID $id not found',
          'TASK_NOT_FOUND',
        ));
      }
      
      return Right(taskModel.toEntity());
    } catch (e) {
      return Left(DatabaseFailure(
        'Failed to get task by ID: ${e.toString()}',
        'GET_TASK_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByDate(DateTime date) async {
    try {
      final taskModels = await _localDataSource.getTasksForDate(date);
      final tasks = taskModels.map((model) => model.toEntity()).toList();
      
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure(
        'Failed to get tasks by date: ${e.toString()}',
        'GET_TASKS_BY_DATE_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    try {
      final taskModels = await _localDataSource.getAllTasks();
      final tasks = taskModels.map((model) => model.toEntity()).toList();
      
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure(
        'Failed to get all tasks: ${e.toString()}',
        'GET_ALL_TASKS_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> searchTasks(String searchTerm) async {
    try {
      final taskModels = await _localDataSource.searchTasks(searchTerm);
      final tasks = taskModels.map((model) => model.toEntity()).toList();
      
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure(
        'Failed to search tasks: ${e.toString()}',
        'SEARCH_TASKS_ERROR',
      ));
    }
  }
}