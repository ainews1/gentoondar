import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import 'pomodoro_marker.dart';

class TaskDurationBlock extends ConsumerWidget {
  final Task task;
  final double hourHeight;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TaskDurationBlock({
    Key? key,
    required this.task,
    this.hourHeight = 60.0,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockHeight = _calculateBlockHeight();
    final topOffset = _calculateTopOffset();
    
    return Positioned(
      top: topOffset,
      left: 2,
      right: 2,
      height: blockHeight,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: task.isCompleted 
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.8)
                : Theme.of(context).colorScheme.primary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: task.isCompleted
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (blockHeight > 30) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('HH:mm').format(task.startTime)} (${task.durationMinutes}min)',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Pomodoro session markers
                  PomodoroCalendarMarker(taskId: task.id),
                ],
                if (task.description?.isNotEmpty == true && blockHeight > 50) ...[
                  const SizedBox(height: 2),
                  Expanded(
                    child: Text(
                      task.description!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 9,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateBlockHeight() {
    // Convert duration to pixels based on hourHeight
    final durationHours = task.durationMinutes / 60.0;
    return durationHours * hourHeight;
  }

  double _calculateTopOffset() {
    // Calculate offset from 6 AM (start of grid)
    final startOfDay = DateTime(task.startTime.year, task.startTime.month, task.startTime.day, 6);
    final minutesFromStart = task.startTime.difference(startOfDay).inMinutes;
    
    // Convert to pixels
    return (minutesFromStart / 60.0) * hourHeight;
  }
}