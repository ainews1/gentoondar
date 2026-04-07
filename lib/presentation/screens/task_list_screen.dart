import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_calendar_app/presentation/providers/task_providers.dart';
import 'package:task_calendar_app/presentation/widgets/tasks/task_list.dart';
import 'package:task_calendar_app/presentation/navigation/app_router.dart';

/// Main screen displaying the task list with navigation and date selection.
/// Provides the primary interface for task management with CRUD operations.
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks for today when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedDate = ref.read(selectedDateProvider);
      ref.read(taskListProvider.notifier).loadTasks(selectedDate);
    });
  }

  /// Show date picker to select different date
  Future<void> _selectDate() async {
    final currentDate = ref.read(selectedDateProvider);
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select date to view tasks',
    );

    if (selectedDate != null && selectedDate != currentDate) {
      ref.read(selectedDateProvider.notifier).state = selectedDate;
    }
  }

  /// Navigate to today's tasks
  void _goToToday() {
    final today = DateTime.now();
    ref.read(selectedDateProvider.notifier).state = today;
  }

  /// Navigate to previous day
  void _goToPreviousDay() {
    final currentDate = ref.read(selectedDateProvider);
    final previousDay = currentDate.subtract(const Duration(days: 1));
    ref.read(selectedDateProvider.notifier).state = previousDay;
  }

  /// Navigate to next day
  void _goToNextDay() {
    final currentDate = ref.read(selectedDateProvider);
    final nextDay = currentDate.add(const Duration(days: 1));
    ref.read(selectedDateProvider.notifier).state = nextDay;
  }

  /// Format date for display in app bar
  String _formatDateForAppBar(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == tomorrow) {
      return 'Tomorrow';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  /// Check if selected date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate == today;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _selectDate,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_formatDateForAppBar(selectedDate)),
              const SizedBox(width: 8),
              Icon(
                Icons.calendar_month,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          // Today button (only show if not already on today)
          if (!_isToday(selectedDate))
            TextButton(
              onPressed: _goToToday,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Today'),
            ),
          
          // Add task button
          IconButton(
            onPressed: () => AppNavigation.goToNewTask(context),
            icon: const Icon(Icons.add),
            tooltip: 'Add new task',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Date navigation
                IconButton(
                  onPressed: _goToPreviousDay,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous day',
                  iconSize: 28,
                  color: theme.colorScheme.onPrimary,
                ),
                
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          DateFormat('EEEE, MMM dd').format(selectedDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                IconButton(
                  onPressed: _goToNextDay,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next day',
                  iconSize: 28,
                  color: theme.colorScheme.onPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
      
      body: Column(
        children: [
          // Task summary
          TaskListSummary(date: selectedDate),
          
          // Divider
          const Divider(height: 1),
          
          // Task list
          Expanded(
            child: AutoTaskList(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => AppNavigation.goToNewTask(context),
        tooltip: 'Add new task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Alternative compact task list screen for smaller displays or embedded use
class CompactTaskListScreen extends ConsumerWidget {
  const CompactTaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: () => AppNavigation.goToNewTask(context),
            icon: const Icon(Icons.add),
            tooltip: 'Add task',
          ),
        ],
      ),
      body: const AutoTaskList(isCompact: true),
    );
  }
}

/// Task list screen with specific date filter (useful for calendar integration)
class DateFilteredTaskListScreen extends ConsumerWidget {
  final DateTime date;
  final String? title;

  const DateFilteredTaskListScreen({
    super.key,
    required this.date,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? DateFormat('MMM dd, yyyy').format(date)),
        actions: [
          IconButton(
            onPressed: () {
              // Set the global selected date and navigate to new task
              ref.read(selectedDateProvider.notifier).state = date;
              AppNavigation.goToNewTask(context);
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add task for this date',
          ),
        ],
      ),
      body: Column(
        children: [
          TaskListSummary(date: date),
          const Divider(height: 1),
          Expanded(
            child: TaskList(filterDate: date),
          ),
        ],
      ),
    );
  }
}