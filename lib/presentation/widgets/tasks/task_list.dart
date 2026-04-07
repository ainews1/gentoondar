import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/presentation/providers/task_providers.dart';
import 'package:task_calendar_app/presentation/widgets/tasks/task_card.dart';
import 'package:task_calendar_app/presentation/navigation/app_router.dart';

/// Scrollable list widget for displaying tasks with proper state management.
/// Handles loading, error, and empty states with pull-to-refresh functionality.
class TaskList extends ConsumerWidget {
  /// Whether to use compact card layout for dense displays
  final bool isCompact;
  
  /// Optional date filter for displaying tasks from specific date
  final DateTime? filterDate;

  const TaskList({
    super.key,
    this.isCompact = false,
    this.filterDate,
  });

  /// Refresh tasks from data source
  Future<void> _refreshTasks(WidgetRef ref) async {
    final date = filterDate ?? ref.read(selectedDateProvider);
    await ref.read(taskListProvider.notifier).loadTasks(date);
  }

  /// Show error snack bar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the task list provider for reactive updates
    final taskListState = ref.watch(taskListProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return RefreshIndicator(
      onRefresh: () => _refreshTasks(ref),
      child: taskListState.when(
        // Loading state
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),

        // Error state
        error: (error, stackTrace) => _ErrorView(
          error: error,
          onRetry: () => _refreshTasks(ref),
          onShowDetails: () => _showErrorSnackBar(
            context, 
            'Error details: ${error.toString()}',
          ),
        ),

        // Data state
        data: (tasks) {
          // Filter tasks if date filter is specified
          final filteredTasks = filterDate != null 
              ? tasks.where((task) {
                  final taskDate = task.startTime.toLocal();
                  final filterDateLocal = filterDate!.toLocal();
                  return taskDate.year == filterDateLocal.year &&
                         taskDate.month == filterDateLocal.month &&
                         taskDate.day == filterDateLocal.day;
                }).toList()
              : tasks;

          if (filteredTasks.isEmpty) {
            return _EmptyTasksView(
              selectedDate: filterDate ?? selectedDate,
              onAddTask: () => AppNavigation.goToNewTask(context),
            );
          }

          // Sort tasks by start time
          filteredTasks.sort((a, b) => a.startTime.compareTo(b.startTime));

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: isCompact ? 8 : 0,
            ),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              
              return isCompact 
                  ? TaskCardCompact(task: task)
                  : TaskCard(task: task);
            },
          );
        },
      ),
    );
  }
}

/// Empty state widget when no tasks are available
class _EmptyTasksView extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onAddTask;

  const _EmptyTasksView({
    required this.selectedDate,
    required this.onAddTask,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'today';
    } else if (targetDate == tomorrow) {
      return 'tomorrow';
    } else {
      return 'on ${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No tasks ${_formatDate(selectedDate)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first task',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error view with retry functionality
class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final VoidCallback? onShowDetails;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load tasks. Please try again.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                if (onShowDetails != null) ...[
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: onShowDetails,
                    child: const Text('Details'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Task list with automatic date-based loading
class AutoTaskList extends ConsumerStatefulWidget {
  /// Whether to use compact card layout
  final bool isCompact;

  const AutoTaskList({
    super.key,
    this.isCompact = false,
  });

  @override
  ConsumerState<AutoTaskList> createState() => _AutoTaskListState();
}

class _AutoTaskListState extends ConsumerState<AutoTaskList> {
  @override
  void initState() {
    super.initState();
    // Load tasks for selected date on widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedDate = ref.read(selectedDateProvider);
      ref.read(taskListProvider.notifier).loadTasks(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to selected date changes and reload tasks
    ref.listen(selectedDateProvider, (previous, next) {
      if (previous != next) {
        ref.read(taskListProvider.notifier).loadTasks(next);
      }
    });

    return TaskList(
      isCompact: widget.isCompact,
      filterDate: ref.watch(selectedDateProvider),
    );
  }
}

/// Helper widget for task count display
class TaskListSummary extends ConsumerWidget {
  final DateTime date;

  const TaskListSummary({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final tasksAsync = ref.watch(getTasksByDateProvider(date));
        
        return tasksAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (tasks) {
            if (tasks.isEmpty) return const SizedBox.shrink();
            
            final completed = tasks.where((t) => t.isCompleted).length;
            final total = tasks.length;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$completed of $total tasks completed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (completed == total && total > 0)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}