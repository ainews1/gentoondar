import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../providers/week_view_providers.dart';
import '../../providers/task_providers.dart';
import '../common/responsive_layout.dart';
import 'time_slot_grid.dart';
import 'task_duration_block.dart';

class WeekCalendarWidget extends ConsumerWidget {
  const WeekCalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekTasksAsync = ref.watch(weekTasksProvider);
    final weekDays = ref.watch(weekDaysProvider);
    final currentWeek = ref.watch(currentWeekProvider);

    return Column(
      children: [
        // Week navigation header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _navigateWeek(ref, -1),
                tooltip: 'Previous week',
              ),
              Expanded(
                child: Text(
                  _formatWeekTitle(weekDays.first, weekDays.last),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _navigateWeek(ref, 1),
                tooltip: 'Next week',
              ),
            ],
          ),
        ),
        const Divider(),
        // Week calendar content
        Expanded(
          child: weekTasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading week tasks',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            data: (tasks) => ResponsiveLayout(
              child: _buildWeekGrid(context, ref, weekDays, tasks),
              mediumChild: _buildWeekGrid(context, ref, weekDays, tasks),
              largeChild: _buildWeekGrid(context, ref, weekDays, tasks),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekGrid(
    BuildContext context, 
    WidgetRef ref, 
    List<DateTime> weekDays, 
    List<Task> tasks
  ) {
    // Group tasks by day
    final tasksByDay = <DateTime, List<Task>>{};
    for (final task in tasks) {
      final taskDate = DateTime(
        task.startTime.year, 
        task.startTime.month, 
        task.startTime.day
      );
      tasksByDay[taskDate] = (tasksByDay[taskDate] ?? [])..add(task);
    }

    return Stack(
      children: [
        // Time slot grid
        TimeSlotGrid(
          weekDays: weekDays,
          hourHeight: 60.0,
          onTimeSlotTap: (day, time) => _onTimeSlotTap(context, ref, day, time),
        ),
        // Task blocks overlay
        ...weekDays.asMap().entries.expand((entry) {
          final dayIndex = entry.key;
          final day = entry.value;
          final dayTasks = tasksByDay[day] ?? [];
          final dayWidth = (MediaQuery.of(context).size.width - 60) / 7;
          
          return dayTasks.map((task) => Positioned(
            left: 60 + (dayIndex * dayWidth),
            width: dayWidth,
            child: TaskDurationBlock(
              task: task,
              hourHeight: 60.0,
              onTap: () => _onTaskTap(context, ref, task),
              onLongPress: () => _onTaskLongPress(context, ref, task),
            ),
          ));
        }).toList(),
      ],
    );
  }

  void _navigateWeek(WidgetRef ref, int direction) {
    final currentWeek = ref.read(currentWeekProvider);
    final newWeek = currentWeek.add(Duration(days: 7 * direction));
    ref.read(currentWeekProvider.notifier).state = newWeek;
  }

  String _formatWeekTitle(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('d, yyyy').format(end)}';
    } else {
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    }
  }

  void _onTimeSlotTap(BuildContext context, WidgetRef ref, DateTime day, DateTime time) {
    // TODO: Navigate to create task with pre-filled date and time
    final selectedDateTime = DateTime(
      day.year, 
      day.month, 
      day.day, 
      time.hour, 
      time.minute
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Time slot tapped: ${DateFormat('MMM d, HH:mm').format(selectedDateTime)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTaskTap(BuildContext context, WidgetRef ref, Task task) {
    // TODO: Navigate to edit task
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task tapped: ${task.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTaskLongPress(BuildContext context, WidgetRef ref, Task task) {
    // TODO: Show task action menu
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description?.isNotEmpty == true)
              Text(task.description!),
            const SizedBox(height: 8),
            Text(
              'Time: ${DateFormat('MMM d, HH:mm').format(task.startTime)}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              'Duration: ${task.durationMinutes} minutes',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}