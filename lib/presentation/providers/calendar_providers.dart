import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks_in_date_range.dart';
import '../../domain/usecases/get_tasks_by_date.dart';
import 'task_providers.dart';

// Selected date state
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Current month being viewed
final currentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Use case provider for date range queries
final getTasksInDateRangeProvider = Provider<GetTasksInDateRange>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTasksInDateRange(repository);
});

// Tasks for current month (for visual indicators)
final monthTasksProvider = FutureProvider<List<Task>>((ref) async {
  final currentMonth = ref.watch(currentMonthProvider);
  final getTasksInDateRange = ref.watch(getTasksInDateRangeProvider);
  
  final startOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
  final endOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
  
  final result = await getTasksInDateRange(DateRangeParams(
    startDate: startOfMonth,
    endDate: endOfMonth,
  ));
  
  return result.fold(
    (failure) => throw Exception('Failed to load tasks for month'),
    (tasks) => tasks,
  );
});

// Use case provider for date queries
final getTasksByDateUseCaseCalProvider = Provider<GetTasksByDate>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTasksByDate(repository);
});

// Tasks for selected date
final selectedDateTasksProvider = FutureProvider<List<Task>>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final getTasksByDate = ref.watch(getTasksByDateUseCaseCalProvider);
  
  final result = await getTasksByDate(GetTasksByDateParams(date: selectedDate));
  
  return result.fold(
    (failure) => throw Exception('Failed to load tasks for selected date'),
    (tasks) => tasks,
  );
});

// Calendar format state (month/2weeks/week)
final calendarFormatProvider = StateProvider<CalendarFormat>((ref) => CalendarFormat.month);