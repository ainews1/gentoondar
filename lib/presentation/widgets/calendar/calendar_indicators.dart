import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';

class TaskIndicator extends StatelessWidget {
  final List<Task> tasks;
  final bool isSelected;
  final bool isToday;

  const TaskIndicator({
    Key? key,
    required this.tasks,
    this.isSelected = false,
    this.isToday = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    final completedCount = tasks.where((task) => task.isCompleted).length;
    final totalCount = tasks.length;
    final hasIncomplete = completedCount < totalCount;

    return Positioned(
      bottom: 2,
      right: 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Task count indicator
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _getIndicatorColor(context, hasIncomplete),
              shape: BoxShape.circle,
              border: isSelected || isToday
                  ? Border.all(color: Colors.white, width: 1)
                  : null,
            ),
            child: Center(
              child: Text(
                totalCount > 99 ? '99+' : totalCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: totalCount > 9 ? 8 : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Completion indicator (if partially complete)
          if (completedCount > 0 && hasIncomplete) ...[
            const SizedBox(width: 2),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
                border: isSelected || isToday
                    ? Border.all(color: Colors.white, width: 0.5)
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getIndicatorColor(BuildContext context, bool hasIncomplete) {
    if (hasIncomplete) {
      return Theme.of(context).colorScheme.primary;
    } else {
      // All tasks completed
      return Theme.of(context).colorScheme.secondary;
    }
  }
}

// Helper function to build event markers for table_calendar
List<Widget> buildEventMarkers(BuildContext context, DateTime day, List<Task> tasks) {
  if (tasks.isEmpty) return [];

  final completedCount = tasks.where((task) => task.isCompleted).length;
  final totalCount = tasks.length;

  return [
    Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: completedCount == totalCount
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      width: 6,
      height: 6,
      child: totalCount > 3
          ? Center(
              child: Text(
                totalCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    ),
  ];
}

// Custom calendar day builder
Widget buildCalendarDay(
  BuildContext context,
  DateTime day,
  DateTime focusedDay,
  List<Task> dayTasks,
  bool isSelected,
  bool isToday,
) {
  return Container(
    margin: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : isToday
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : null,
      borderRadius: BorderRadius.circular(8),
      border: isToday && !isSelected
          ? Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            )
          : null,
    ),
    child: Stack(
      children: [
        // Day number
        Center(
          child: Text(
            day.day.toString(),
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : isToday
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        // Task indicators
        TaskIndicator(
          tasks: dayTasks,
          isSelected: isSelected,
          isToday: isToday,
        ),
      ],
    ),
  );
}