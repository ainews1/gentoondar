import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/domain/repositories/task_repository.dart';
import 'package:task_calendar_app/domain/usecases/create_task.dart';
import 'package:task_calendar_app/domain/usecases/update_task.dart';
import 'package:task_calendar_app/domain/usecases/delete_task.dart';
import 'package:task_calendar_app/domain/usecases/get_task_by_id.dart';
import 'package:task_calendar_app/domain/usecases/get_tasks_by_date.dart';
import 'package:task_calendar_app/data/repositories/task_repository_impl.dart';
import 'package:task_calendar_app/data/datasources/local/task_local_datasource.dart';

// =============================================================================
// Data Layer Providers
// =============================================================================

/// Provides TaskLocalDataSource instance
final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSource();
});

/// Provides TaskRepository implementation with injected data source
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final localDataSource = ref.watch(taskLocalDataSourceProvider);
  return TaskRepositoryImpl(localDataSource: localDataSource);
});

// =============================================================================
// Use Case Providers
// =============================================================================

/// Provides CreateTask use case
final createTaskUseCaseProvider = Provider<CreateTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CreateTask(repository);
});

/// Provides UpdateTask use case
final updateTaskUseCaseProvider = Provider<UpdateTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return UpdateTask(repository);
});

/// Provides DeleteTask use case
final deleteTaskUseCaseProvider = Provider<DeleteTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return DeleteTask(repository);
});

/// Provides GetTaskById use case
final getTaskByIdUseCaseProvider = Provider<GetTaskById>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTaskById(repository);
});

/// Provides GetTasksByDate use case
final getTasksByDateUseCaseProvider = Provider<GetTasksByDate>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTasksByDate(repository);
});

// =============================================================================
// Individual Task Provider (Family)
// =============================================================================

/// FutureProvider for getting a single task by ID
final getTaskByIdProvider = FutureProvider.family<Task?, int>((ref, id) async {
  final useCase = ref.watch(getTaskByIdUseCaseProvider);
  final result = await useCase(GetTaskByIdParams(id: id));
  
  return result.fold(
    (failure) => null, // Return null on failure
    (task) => task,
  );
});

/// FutureProvider for getting tasks by date
final getTasksByDateProvider = FutureProvider.family<List<Task>, DateTime>((ref, date) async {
  final useCase = ref.watch(getTasksByDateUseCaseProvider);
  final result = await useCase(GetTasksByDateParams(date: date));
  
  return result.fold(
    (failure) => <Task>[], // Return empty list on failure
    (tasks) => tasks,
  );
});

// =============================================================================
// State Management Providers
// =============================================================================

/// StateProvider for currently selected date (used by calendar)
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// AsyncNotifierProvider for task list state management
final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<Task>>(
  () => TaskListNotifier(),
);

/// Notifier for managing task list state with CRUD operations
class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    // Initialize with empty list
    return [];
  }

  /// Load tasks for a specific date
  Future<void> loadTasks(DateTime date) async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(getTasksByDateUseCaseProvider);
    final result = await useCase(GetTasksByDateParams(date: date));
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (tasks) => AsyncValue.data(tasks),
    );
  }

  /// Add a new task to the list
  Future<void> addTask(Task task) async {
    final useCase = ref.read(createTaskUseCaseProvider);
    final result = await useCase(CreateTaskParams(task: task));
    
    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (newTask) async {
        // Update state with new task added
        final currentTasks = state.valueOrNull ?? [];
        final updatedTasks = [...currentTasks, newTask];
        state = AsyncValue.data(updatedTasks);
        
        // Refresh related providers
        _invalidateRelatedProviders(newTask.startTime);
      },
    );
  }

  /// Update an existing task in the list
  Future<void> updateTask(Task task) async {
    final useCase = ref.read(updateTaskUseCaseProvider);
    final result = await useCase(UpdateTaskParams(task: task));
    
    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (updatedTask) async {
        // Update state with modified task
        final currentTasks = state.valueOrNull ?? [];
        final updatedTasks = currentTasks.map((t) => 
          t.id == updatedTask.id ? updatedTask : t
        ).toList();
        state = AsyncValue.data(updatedTasks);
        
        // Refresh related providers
        _invalidateRelatedProviders(updatedTask.startTime);
      },
    );
  }

  /// Remove a task from the list
  Future<void> removeTask(int id) async {
    final useCase = ref.read(deleteTaskUseCaseProvider);
    final result = await useCase(DeleteTaskParams(id: id));
    
    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) async {
        // Update state with task removed
        final currentTasks = state.valueOrNull ?? [];
        final removedTask = currentTasks.where((t) => t.id == id).firstOrNull;
        final updatedTasks = currentTasks.where((t) => t.id != id).toList();
        state = AsyncValue.data(updatedTasks);
        
        // Refresh related providers if we found the removed task
        if (removedTask != null) {
          _invalidateRelatedProviders(removedTask.startTime);
        }
      },
    );
  }

  /// Helper method to invalidate related providers when tasks change
  void _invalidateRelatedProviders(DateTime taskDate) {
    // Invalidate date-specific providers
    ref.invalidate(getTasksByDateProvider(taskDate));
    
    // Invalidate any calendar-related providers that might cache task data
    // (This ensures calendar views update when tasks change)
  }
}

// =============================================================================
// Mutation Providers for UI Operations
// =============================================================================

/// AsyncNotifierProvider for create task operations
final createTaskProvider = AsyncNotifierProvider<CreateTaskNotifier, Task?>(
  () => CreateTaskNotifier(),
);

/// Notifier for handling task creation
class CreateTaskNotifier extends AsyncNotifier<Task?> {
  @override
  Future<Task?> build() async {
    return null;
  }

  /// Create a new task
  Future<void> createTask(Task task) async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(createTaskUseCaseProvider);
    final result = await useCase(CreateTaskParams(task: task));
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (newTask) {
        // Refresh the task list for the task's date
        ref.read(taskListProvider.notifier).loadTasks(newTask.startTime);
        return AsyncValue.data(newTask);
      },
    );
  }
}

/// AsyncNotifierProvider for update task operations
final updateTaskProvider = AsyncNotifierProvider<UpdateTaskNotifier, Task?>(
  () => UpdateTaskNotifier(),
);

/// Notifier for handling task updates
class UpdateTaskNotifier extends AsyncNotifier<Task?> {
  @override
  Future<Task?> build() async {
    return null;
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(updateTaskUseCaseProvider);
    final result = await useCase(UpdateTaskParams(task: task));
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (updatedTask) {
        // Refresh the task list for the task's date
        ref.read(taskListProvider.notifier).loadTasks(updatedTask.startTime);
        return AsyncValue.data(updatedTask);
      },
    );
  }
}

/// AsyncNotifierProvider for delete task operations
final deleteTaskProvider = AsyncNotifierProvider<DeleteTaskNotifier, bool>(
  () => DeleteTaskNotifier(),
);

/// Notifier for handling task deletion
class DeleteTaskNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return false;
  }

  /// Delete a task by ID
  Future<void> deleteTask(int id, DateTime taskDate) async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(deleteTaskUseCaseProvider);
    final result = await useCase(DeleteTaskParams(id: id));
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) {
        // Refresh the task list for the task's date
        ref.read(taskListProvider.notifier).loadTasks(taskDate);
        return const AsyncValue.data(true);
      },
    );
  }
}

// =============================================================================
// Utility Extensions for Error Handling
// =============================================================================

/// Extension to safely get value from AsyncValue or return null
extension AsyncValueExtensions<T> on AsyncValue<T> {
  T? get safeValue => when(
    data: (value) => value,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Helper function to convert Either<Failure, T> to AsyncValue<T>
AsyncValue<T> eitherToAsyncValue<T>(Either<Failure, T> either) {
  return either.fold(
    (failure) => AsyncValue.error(failure, StackTrace.current),
    (value) => AsyncValue.data(value),
  );
}