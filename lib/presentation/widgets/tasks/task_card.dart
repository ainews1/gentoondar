import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/presentation/providers/task_providers.dart';
import 'package:task_calendar_app/presentation/providers/pomodoro_timer_providers.dart';
import 'package:task_calendar_app/presentation/navigation/app_router.dart';
import 'package:task_calendar_app/presentation/theme/app_theme.dart';
import 'package:task_calendar_app/presentation/widgets/pomodoro/pomodoro_badge.dart';

/// Card widget for displaying individual tasks with actions.
/// Shows task information and provides edit, delete, completion toggle,
/// Pomodoro badge, and expandable "Start Pomodoro" button.
class TaskCard extends ConsumerStatefulWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _isExpanded = false;

  Task get task => widget.task;

  /// Format date and time for display
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy at h:mm a').format(dateTime.toLocal());
  }

  /// Format duration for display
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours ${hours == 1 ? 'hr' : 'hrs'}';
    }
    return '$hours hr $remainingMinutes min';
  }

  /// Show delete confirmation dialog
  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Handle task completion toggle
  void _toggleCompletion(WidgetRef ref) {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now().toUtc(),
    );
    
    ref.read(updateTaskProvider.notifier).updateTask(updatedTask);
  }

  /// Handle task deletion
  void _deleteTask(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showDeleteDialog(context);
    if (confirmed == true) {
      ref.read(deleteTaskProvider.notifier).deleteTask(
        task.id,
        task.startTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine visual style based on completion status
    final isCompleted = task.isCompleted;
    final titleStyle = isCompleted
        ? AppTextStyles.taskTitleCompleted
        : AppTextStyles.taskTitle;

    final cardColor = isCompleted
        ? colorScheme.surfaceVariant.withOpacity(0.5)
        : colorScheme.surface;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with checkbox and title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Completion checkbox
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: isCompleted,
                        onChanged: (_) => _toggleCompletion(ref),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: titleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: AppTextStyles.taskDescription.copyWith(
                              color: isCompleted
                                  ? Colors.grey.shade500
                                  : null,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Pomodoro badge
                  PomodoroBadge(taskId: task.id),
                  const SizedBox(width: 4),

                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      IconButton(
                        onPressed: () => AppNavigation.goToEditTask(context, task),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit task',
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        color: colorScheme.primary,
                      ),

                      // Delete button
                      IconButton(
                        onPressed: () => _deleteTask(context, ref),
                        icon: const Icon(Icons.delete_outlined),
                        tooltip: 'Delete task',
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        color: colorScheme.error,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Task metadata row
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  // Date and time
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(task.startTime),
                        style: AppTextStyles.taskMetadata,
                      ),
                    ],
                  ),

                  // Duration
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(task.durationMinutes),
                        style: AppTextStyles.taskMetadata,
                      ),
                    ],
                  ),

                  // Completion status indicator
                  if (isCompleted)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: AppTextStyles.taskMetadata.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Expanded action row with Start Pomodoro button
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _startPomodoro(ref),
                      icon: const Icon(Icons.timer, size: 18),
                      label: const Text('Start Pomodoro'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53935),
                        side: const BorderSide(color: Color(0xFFE53935)),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => AppNavigation.goToEditTask(context, task),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteTask(context, ref),
                      icon: Icon(Icons.delete, size: 16, color: colorScheme.error),
                      label: Text('Delete', style: TextStyle(color: colorScheme.error)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Start a Pomodoro session for this task
  void _startPomodoro(WidgetRef ref) {
    final notifier = ref.read(pomodoroTimerProvider.notifier);
    notifier.selectTask(task.id);
    notifier.startWork();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pomodoro started for "${task.title}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Compact version of TaskCard for dense layouts
class TaskCardCompact extends ConsumerWidget {
  final Task task;

  const TaskCardCompact({super.key, required this.task});

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }

  void _toggleCompletion(WidgetRef ref) {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now().toUtc(),
    );
    
    ref.read(updateTaskProvider.notifier).updateTask(updatedTask);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        dense: true,
        leading: SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: isCompleted,
            onChanged: (_) => _toggleCompletion(ref),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        title: Text(
          task.title,
          style: isCompleted 
              ? AppTextStyles.taskTitleCompleted
              : AppTextStyles.taskTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${_formatTime(task.startTime)} • ${_formatDuration(task.durationMinutes)}',
          style: AppTextStyles.taskMetadata,
        ),
        trailing: IconButton(
          onPressed: () => AppNavigation.goToEditTask(context, task),
          icon: const Icon(Icons.edit_outlined),
          iconSize: 18,
          tooltip: 'Edit task',
        ),
        onTap: () => AppNavigation.goToEditTask(context, task),
      ),
    );
  }
}