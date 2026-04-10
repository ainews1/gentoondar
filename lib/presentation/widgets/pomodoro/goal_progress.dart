import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pomodoro_session_providers.dart';
import '../../providers/pomodoro_settings_providers.dart';

/// Linear progress bar showing completed sessions vs daily goal (D-24).
/// Reads daily count and settings for target.
class GoalProgress extends ConsumerWidget {
  const GoalProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(dailyPomodoroCountProvider);
    final settingsAsync = ref.watch(pomodoroSettingsProvider);

    final completed = countAsync.valueOrNull ?? 0;
    final target = settingsAsync.valueOrNull?.dailyGoal ?? 8;
    final progress = target > 0 ? (completed / target).clamp(0.0, 1.0) : 0.0;

    return Semantics(
      label: 'Daily goal: $completed of $target sessions completed',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Goal: $completed/$target',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
            ),
          ),
        ],
      ),
    );
  }
}
