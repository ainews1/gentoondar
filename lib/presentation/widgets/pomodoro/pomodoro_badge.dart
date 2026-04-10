import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/pomodoro_session_providers.dart';

/// Small circular badge displaying the completed Pomodoro session count
/// for a given task. Shown on task cards in the task list view.
/// Only renders when count > 0.
class PomodoroBadge extends ConsumerWidget {
  /// The task ID to display session count for
  final int taskId;

  const PomodoroBadge({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(taskPomodoroCountProvider(taskId));

    return countAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (count) {
        if (count == 0) return const SizedBox.shrink();

        return Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer,
                size: 10,
                color: Color(0xFFE53935),
              ),
              const SizedBox(width: 2),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
