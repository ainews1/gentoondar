import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks_for_week.dart';
import 'task_providers.dart';

// Current week being viewed (any date within the week)
final currentWeekProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Use case provider for week queries
final getTasksForWeekProvider = Provider<GetTasksForWeek>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTasksForWeek(repository);
});

// Tasks for current week
final weekTasksProvider = FutureProvider<List<Task>>((ref) async {
  final currentWeek = ref.watch(currentWeekProvider);
  final getTasksForWeek = ref.watch(getTasksForWeekProvider);
  
  final result = await getTasksForWeek(WeekParams(weekDate: currentWeek));
  
  return result.fold(
    (failure) => throw Exception('Failed to load tasks for week'),
    (tasks) => tasks,
  );
});

// Helper to get start of week (Monday)
final weekStartProvider = Provider<DateTime>((ref) {
  final currentWeek = ref.watch(currentWeekProvider);
  final daysFromMonday = currentWeek.weekday - 1;
  final startOfWeek = currentWeek.subtract(Duration(days: daysFromMonday));
  return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
});

// Helper to get all 7 days of the current week
final weekDaysProvider = Provider<List<DateTime>>((ref) {
  final weekStart = ref.watch(weekStartProvider);
  return List.generate(7, (index) => weekStart.add(Duration(days: index)));
});