import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/update_task.dart';
import '../../../domain/usecases/delete_task.dart';
import '../../providers/calendar_providers.dart' hide selectedDateProvider;
import '../../providers/task_providers.dart';

class DateTaskListWidget extends ConsumerWidget {
  final bool showHeader;
  final VoidCallback? onTaskTap;
  final VoidCallback? onCreateTask;

  const DateTaskListWidget({
    Key? key,
    this.showHeader = true,
    this.onTaskTap,
    this.onCreateTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedDateTasksAsync = ref.watch(selectedDateTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tasks for ${DateFormat('EEEE, MMM d').format(selectedDate)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (onCreateTask != null)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onCreateTask,
                    tooltip: 'Add task for this date',
                  ),
              ],
            ),
          ),
          const Divider(),
        ],
        Expanded(
          child: selectedDateTasksAsync.when(
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
                    'Error loading tasks',
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
            data: (tasks) {
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks for this date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (onCreateTask != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add your first task'),
                          onPressed: onCreateTask,
                        ),
                      ],
                    ],
                  ),
                );
              }

              // Sort tasks by time if available, then by creation order
              final sortedTasks = [...tasks];
              sortedTasks.sort((a, b) {
                // Both tasks have startTime, compare them
                final timeComparison = a.startTime.compareTo(b.startTime);
                if (timeComparison != 0) return timeComparison;
                return a.id.compareTo(b.id);
              });

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: sortedTasks.length,
                itemBuilder: (context, index) {
                  final task = sortedTasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description?.isNotEmpty == true)
                            Text(task.description!),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Text(
                                  DateFormat('h:mm a').format(task.startTime),
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                                Text(
                                  ' • ${task.durationMinutes}min',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      leading: GestureDetector(
                        onTap: () async {
                          final updateTaskProvider = ref.read(updateTaskUseCaseProvider);
                          final updatedTask = task.copyWith(
                            isCompleted: !task.isCompleted,
                            updatedAt: DateTime.now().toUtc(),
                          );
                          await updateTaskProvider.call(UpdateTaskParams(task: updatedTask));
                          // Refresh the task list
                          ref.invalidate(selectedDateTasksProvider);
                        },
                        child: Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: task.isCompleted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              // TODO: Navigate to edit task screen
                              if (onTaskTap != null) onTaskTap!();
                              break;
                            case 'delete':
                              _showDeleteConfirmation(context, ref, task);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Delete'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      onTap: onTaskTap,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final deleteTaskProvider = ref.read(deleteTaskUseCaseProvider);
              await deleteTaskProvider.call(DeleteTaskParams(id: task.id));
              // Refresh the task list
              ref.invalidate(selectedDateTasksProvider);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}