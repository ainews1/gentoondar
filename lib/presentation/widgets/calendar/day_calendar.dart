import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../providers/day_view_providers.dart';
import '../../providers/task_providers.dart';
import '../common/responsive_layout.dart';
import 'hourly_timeline.dart';
import 'day_task_scheduler.dart';

class DayCalendarWidget extends ConsumerWidget {
  const DayCalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayTasksAsync = ref.watch(dayTasksProvider);
    final currentDay = ref.watch(currentDayProvider);
    final dayTitle = ref.watch(dayTitleProvider);
    final isToday = ref.watch(isDayTodayProvider);

    return Column(
      children: [
        // Day navigation header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _navigateDay(ref, -1),
                tooltip: 'Previous day',
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      dayTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isToday ? Theme.of(context).primaryColor : null,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isToday && !['Yesterday', 'Tomorrow'].contains(dayTitle))
                      Text(
                        DateFormat('MMMM d, yyyy').format(currentDay),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _navigateDay(ref, 1),
                tooltip: 'Next day',
              ),
            ],
          ),
        ),
        const Divider(),
        
        // Day calendar content
        Expanded(
          child: dayTasksAsync.when(
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
                    'Error loading day tasks',
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
              child: _buildDaySchedule(context, ref, currentDay, tasks),
              mediumChild: _buildDaySchedule(context, ref, currentDay, tasks),
              largeChild: _buildDaySchedule(context, ref, currentDay, tasks),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySchedule(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    List<Task> tasks,
  ) {
    final scrollController = ScrollController();
    
    // Auto-scroll to current time if viewing today
    final isToday = ref.watch(isDayTodayProvider);
    if (isToday) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentTime(scrollController);
      });
    }

    return Container(
      child: Row(
        children: [
          // Hourly timeline
          HourlyTimeline(
            day: day,
            hourHeight: 80.0,
            onTimeSlotTap: (time) => _onTimeSlotTap(context, ref, time),
            scrollController: scrollController,
          ),
          
          // Task schedule area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // Background grid lines (hourly divisions)
                  _buildBackgroundGrid(context),
                  
                  // Current time indicator (if today)
                  if (isToday) _buildCurrentTimeIndicator(context),
                  
                  // Task scheduler
                  DayTaskScheduler(
                    day: day,
                    tasks: tasks,
                    hourHeight: 80.0,
                    onTaskTap: (task) => _onTaskTap(context, ref, task),
                    onTaskLongPress: (task) => _onTaskLongPress(context, ref, task),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGrid(BuildContext context) {
    return Column(
      children: List.generate(24 * 4, (index) {
        final isHourMark = index % 4 == 0;
        return Container(
          height: 80.0 / 4, // Quarter hour height
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isHourMark 
                    ? Theme.of(context).dividerColor.withOpacity(0.5)
                    : Theme.of(context).dividerColor.withOpacity(0.2),
                width: isHourMark ? 0.5 : 0.25,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentTimeIndicator(BuildContext context) {
    final now = DateTime.now();
    final minutesFromMidnight = now.hour * 60 + now.minute;
    final topOffset = (minutesFromMidnight / 60.0) * 80.0;
    
    return Positioned(
      top: topOffset - 1,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateDay(WidgetRef ref, int direction) {
    final currentDay = ref.read(currentDayProvider);
    final newDay = currentDay.add(Duration(days: direction));
    ref.read(currentDayProvider.notifier).state = newDay;
  }

  void _scrollToCurrentTime(ScrollController scrollController) {
    if (!scrollController.hasClients) return;
    
    final now = DateTime.now();
    final minutesFromMidnight = now.hour * 60 + now.minute;
    final scrollOffset = (minutesFromMidnight / 60.0) * 80.0;
    
    // Scroll to show current time in center of screen
    final targetOffset = (scrollOffset - (MediaQuery.of(scrollController.position.context).size.height / 2))
        .clamp(0.0, scrollController.position.maxScrollExtent);
    
    scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onTimeSlotTap(BuildContext context, WidgetRef ref, DateTime time) {
    // TODO: Navigate to create task with pre-filled date and time
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Time slot: ${DateFormat('MMM d, HH:mm').format(time)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTaskTap(BuildContext context, WidgetRef ref, Task task) {
    // TODO: Navigate to edit task
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit: ${task.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTaskLongPress(BuildContext context, WidgetRef ref, Task task) {
    // Show detailed task information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: task.isCompleted 
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(task.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description?.isNotEmpty == true) ...[
              Text(task.description!),
              const SizedBox(height: 12),
            ],
            _buildTaskDetailRow(
              context,
              Icons.schedule,
              'Time',
              DateFormat('MMM d, yyyy • HH:mm').format(task.startTime),
            ),
            _buildTaskDetailRow(
              context,
              Icons.timer,
              'Duration',
              '${task.durationMinutes} minutes',
            ),
            _buildTaskDetailRow(
              context,
              Icons.flag,
              'Status',
              task.isCompleted ? 'Completed' : 'Pending',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Navigate to edit task
              Navigator.of(context).pop();
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}