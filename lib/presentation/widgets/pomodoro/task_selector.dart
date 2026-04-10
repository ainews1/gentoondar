import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pomodoro_timer_providers.dart';
import '../../providers/task_providers.dart';

/// Dropdown selector for linking a task to the Pomodoro timer.
/// Shows today's incomplete tasks with title and start time.
/// Pre-selects the currently linked task if any (D-09, D-10).
class TaskSelector extends ConsumerWidget {
  const TaskSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final tasksAsync = ref.watch(getTasksByDateProvider(todayDate));
    final timerState = ref.watch(pomodoroTimerProvider);
    final notifier = ref.read(pomodoroTimerProvider.notifier);

    return tasksAsync.when(
      data: (tasks) {
        final incompleteTasks =
            tasks.where((t) => !t.isCompleted).toList();

        if (incompleteTasks.isEmpty) {
          return Text(
            'No tasks for today',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          );
        }

        return DropdownButtonFormField<int>(
          initialValue: timerState.linkedTaskId,
          decoration: const InputDecoration(
            labelText: 'Task',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          items: incompleteTasks.map((task) {
            final timeStr = _formatTime(task.startTime);
            final title = task.title.length > 30
                ? '${task.title.substring(0, 30)}...'
                : task.title;
            return DropdownMenuItem<int>(
              value: task.id,
              child: Text(
                '$title - $timeStr',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (taskId) {
            if (taskId != null) {
              notifier.selectTask(taskId);
            }
          },
          hint: const Text('Select a task'),
        );
      },
      loading: () => const SizedBox(
        height: 24,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => Text(
        'Could not load tasks',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }
}
