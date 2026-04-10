import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/pomodoro_session_providers.dart';

/// Small colored dot markers showing completed Pomodoro sessions
/// on calendar day/week view task blocks. Displays up to 4 dots
/// with a "+N" indicator for additional sessions.
class PomodoroCalendarMarker extends ConsumerWidget {
  /// The task ID to display Pomodoro count for
  final int taskId;

  const PomodoroCalendarMarker({
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

        return Padding(
          padding: const EdgeInsets.only(top: 2),
          child: _buildDots(context, count),
        );
      },
    );
  }

  Widget _buildDots(BuildContext context, int count) {
    const dotColor = Color(0x99E53935); // #E53935 at 60% opacity
    const dotSize = 6.0;
    const dotSpacing = 2.0;

    if (count <= 4) {
      // Show all dots
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index < count - 1 ? dotSpacing : 0),
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: const BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      );
    }

    // Show 3 dots + "+N" text
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: dotSpacing),
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: const BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
        Text(
          '+${count - 3}',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
