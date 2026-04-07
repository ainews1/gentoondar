import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../providers/day_view_providers.dart';

class DayTaskScheduler extends ConsumerWidget {
  final DateTime day;
  final List<Task> tasks;
  final double hourHeight;
  final Function(Task)? onTaskTap;
  final Function(Task)? onTaskLongPress;

  const DayTaskScheduler({
    Key? key,
    required this.day,
    required this.tasks,
    this.hourHeight = 80.0,
    this.onTaskTap,
    this.onTaskLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskOverlaps = ref.watch(taskOverlapAnalysisProvider);
    final layoutInfo = _calculateTaskLayout(tasks, taskOverlaps);
    
    return Stack(
      children: tasks.map((task) {
        final layout = layoutInfo[task]!;
        final topOffset = _calculateTopOffset(task);
        final height = _calculateTaskHeight(task);
        
        return Positioned(
          top: topOffset,
          left: layout.leftOffset,
          width: layout.width,
          height: height,
          child: _buildTaskBlock(context, task, layout),
        );
      }).toList(),
    );
  }

  Widget _buildTaskBlock(BuildContext context, Task task, TaskLayout layout) {
    final hasOverlap = layout.overlapColumn > 0;
    
    return GestureDetector(
      onTap: () => onTaskTap?.call(task),
      onLongPress: () => onTaskLongPress?.call(task),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.9)
              : Theme.of(context).colorScheme.primary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: task.isCompleted
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
            width: hasOverlap ? 2 : 1,
          ),
          boxShadow: hasOverlap ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task title
              Text(
                task.title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Time and duration
              const SizedBox(height: 2),
              Text(
                '${DateFormat('HH:mm').format(task.startTime)} • ${task.durationMinutes}min',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10,
                ),
              ),
              
              // Description (if space allows)
              if (task.description?.isNotEmpty == true && _calculateTaskHeight(task) > 60) ...[
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    task.description!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 9,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              
              // Overlap indicator
              if (hasOverlap) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OVERLAP',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTopOffset(Task task) {
    // Calculate minutes from midnight
    final minutesFromMidnight = task.startTime.hour * 60 + task.startTime.minute;
    // Convert to pixels (hourHeight / 60 minutes per hour)
    return (minutesFromMidnight / 60.0) * hourHeight;
  }

  double _calculateTaskHeight(Task task) {
    // Convert duration to pixels
    return (task.durationMinutes / 60.0) * hourHeight;
  }

  Map<Task, TaskLayout> _calculateTaskLayout(List<Task> tasks, Map<Task, List<Task>> overlaps) {
    final layoutInfo = <Task, TaskLayout>{};
    final columnAssignments = <Task, int>{};
    
    // Sort tasks by start time
    final sortedTasks = [...tasks];
    sortedTasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    for (final task in sortedTasks) {
      final overlappingTasks = overlaps[task] ?? [];
      
      if (overlappingTasks.isEmpty) {
        // No overlaps, full width
        layoutInfo[task] = TaskLayout(
          leftOffset: 0,
          width: 280, // Full width minus padding
          overlapColumn: 0,
        );
        columnAssignments[task] = 0;
      } else {
        // Find available column
        final usedColumns = overlappingTasks
            .where((t) => columnAssignments.containsKey(t))
            .map((t) => columnAssignments[t]!)
            .toSet();
        
        int column = 0;
        while (usedColumns.contains(column)) {
          column++;
        }
        
        columnAssignments[task] = column;
        
        final totalColumns = (usedColumns.length + 1).clamp(1, 3); // Max 3 columns
        final columnWidth = 280 / totalColumns;
        
        layoutInfo[task] = TaskLayout(
          leftOffset: column * columnWidth,
          width: columnWidth - 4, // Small gap between columns
          overlapColumn: column,
        );
      }
    }
    
    return layoutInfo;
  }
}

class TaskLayout {
  final double leftOffset;
  final double width;
  final int overlapColumn;

  TaskLayout({
    required this.leftOffset,
    required this.width,
    required this.overlapColumn,
  });
}