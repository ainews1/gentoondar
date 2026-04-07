import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks_by_date.dart';
import 'task_providers.dart';

// Current day being viewed
final currentDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Tasks for current day (reusing existing use case)
final dayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final currentDay = ref.watch(currentDayProvider);
  final getTasksByDate = ref.watch(getTasksByDateProvider);
  
  final result = await getTasksByDate(DateParams(date: currentDay));
  
  return result.fold(
    (failure) => throw Exception('Failed to load tasks for day'),
    (tasks) => tasks,
  );
});

// Helper to check if current day is today
final isDayTodayProvider = Provider<bool>((ref) {
  final currentDay = ref.watch(currentDayProvider);
  final today = DateTime.now();
  return currentDay.year == today.year &&
         currentDay.month == today.month &&
         currentDay.day == today.day;
});

// Helper to get formatted day title
final dayTitleProvider = Provider<String>((ref) {
  final currentDay = ref.watch(currentDayProvider);
  final isToday = ref.watch(isDayTodayProvider);
  
  if (isToday) {
    return 'Today';
  }
  
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));
  final tomorrow = now.add(const Duration(days: 1));
  
  if (currentDay.year == yesterday.year &&
      currentDay.month == yesterday.month &&
      currentDay.day == yesterday.day) {
    return 'Yesterday';
  }
  
  if (currentDay.year == tomorrow.year &&
      currentDay.month == tomorrow.month &&
      currentDay.day == tomorrow.day) {
    return 'Tomorrow';
  }
  
  // Use full date for other days
  final weekday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][currentDay.weekday - 1];
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '$weekday, ${months[currentDay.month - 1]} ${currentDay.day}';
});

// Schedule analysis - task overlap detection
final taskOverlapAnalysisProvider = Provider<Map<Task, List<Task>>>((ref) {
  final dayTasksAsync = ref.watch(dayTasksProvider);
  
  return dayTasksAsync.when(
    data: (tasks) {
      final overlaps = <Task, List<Task>>{};
      
      for (int i = 0; i < tasks.length; i++) {
        final task1 = tasks[i];
        final overlappingTasks = <Task>[];
        
        for (int j = 0; j < tasks.length; j++) {
          if (i == j) continue;
          final task2 = tasks[j];
          
          if (_tasksOverlap(task1, task2)) {
            overlappingTasks.add(task2);
          }
        }
        
        if (overlappingTasks.isNotEmpty) {
          overlaps[task1] = overlappingTasks;
        }
      }
      
      return overlaps;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

bool _tasksOverlap(Task task1, Task task2) {
  final task1End = task1.startTime.add(Duration(minutes: task1.durationMinutes));
  final task2End = task2.startTime.add(Duration(minutes: task2.durationMinutes));
  
  return task1.startTime.isBefore(task2End) && task2.startTime.isBefore(task1End);
}