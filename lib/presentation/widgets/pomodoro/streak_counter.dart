import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pomodoro_session_providers.dart';

/// Fire icon with streak day count (D-25).
/// Shows "Start a streak today!" when streak is 0.
class StreakCounter extends ConsumerWidget {
  const StreakCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(pomodoroStreakProvider);
    final streak = streakAsync.valueOrNull ?? 0;

    return Semantics(
      label: '$streak day focus streak',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 18,
            color: streak > 0
                ? const Color(0xFFFF6D00)
                : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            streak > 0 ? '$streak day streak' : 'Start a streak today!',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }
}
