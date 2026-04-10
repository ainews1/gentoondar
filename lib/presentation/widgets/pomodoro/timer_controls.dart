import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pomodoro_timer_providers.dart';

/// Horizontal row of Pomodoro timer control buttons.
/// Shows Pause/Resume, Skip (break only), and Stop with confirmation dialog.
/// When idle/ready, shows a single Play button to start work.
class TimerControls extends ConsumerWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(pomodoroTimerProvider);
    final notifier = ref.read(pomodoroTimerProvider.notifier);

    // Idle or ready: show single start button
    if (!timerState.isActive) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(
            icon: Icons.play_arrow,
            tooltip: 'Start Work Session',
            onPressed: timerState.phase == PomodoroPhase.ready
                ? () => notifier.startWork()
                : null,
          ),
        ],
      );
    }

    // Active timer: show Pause/Resume, Skip, Stop
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause / Resume toggle
        _ControlButton(
          icon: timerState.isPaused ? Icons.play_arrow : Icons.pause,
          tooltip: timerState.isPaused ? 'Resume' : 'Pause',
          onPressed: () {
            if (timerState.isPaused) {
              notifier.resume();
            } else {
              notifier.pause();
            }
          },
        ),
        const SizedBox(width: 12),
        // Skip (only enabled during breaks per D-14)
        _ControlButton(
          icon: Icons.skip_next,
          tooltip: 'Skip to next session',
          onPressed: (timerState.phase == PomodoroPhase.shortBreak ||
                  timerState.phase == PomodoroPhase.longBreak)
              ? () => notifier.skipBreak()
              : null,
        ),
        const SizedBox(width: 12),
        // Stop with confirmation
        _ControlButton(
          icon: Icons.stop,
          tooltip: 'Stop Session',
          color: const Color(0xFFF44336),
          onPressed: () => _showStopConfirmation(context, notifier),
        ),
      ],
    );
  }

  Future<void> _showStopConfirmation(
    BuildContext context,
    PomodoroTimerNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text(
          'Stop this session? Progress will be saved as a partial session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Going'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('Stop Session'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.stop();
    }
  }
}

/// Individual control button with 48px touch target and filled tonal style.
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton.filledTonal(
        icon: Icon(icon, color: color),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
