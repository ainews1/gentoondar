import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/pomodoro_timer_providers.dart';
import '../../providers/pomodoro_session_providers.dart';
import '../../providers/pomodoro_settings_providers.dart';
import 'timer_countdown.dart';
import 'timer_controls.dart';
import 'task_selector.dart';
import 'goal_progress.dart';
import 'streak_counter.dart';

/// Expandable timer panel that assembles all Pomodoro sub-components (D-02, D-23).
/// Compact mode: 180px height with countdown, controls, task selector, daily stats.
/// Expanded mode: 280px with streak counter (penguin placeholder for Plan 06).
class TimerPanel extends ConsumerStatefulWidget {
  /// Callback to close the panel without stopping the timer.
  final VoidCallback onClose;

  const TimerPanel({super.key, required this.onClose});

  @override
  ConsumerState<TimerPanel> createState() => _TimerPanelState();
}

class _TimerPanelState extends ConsumerState<TimerPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(pomodoroTimerProvider);
    final dailyCountAsync = ref.watch(dailyPomodoroCountProvider);
    final focusMinutesAsync = ref.watch(dailyFocusMinutesProvider);
    final settingsAsync = ref.watch(pomodoroSettingsProvider);

    final dailyCount = dailyCountAsync.valueOrNull ?? 0;
    final focusMinutes = focusMinutesAsync.valueOrNull ?? 0;
    final settings = settingsAsync.valueOrNull;
    final longBreakInterval = settings?.longBreakInterval ?? 4;
    final sessionInCycle =
        (timerState.completedSessions % longBreakInterval) + 1;

    final hours = focusMinutes ~/ 60;
    final mins = focusMinutes % 60;
    final focusText = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    final panelHeight = _isExpanded ? 280.0 : 200.0;

    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.95),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: panelHeight,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: Task selector + settings + close
            Row(
              children: [
                const Expanded(child: TaskSelector()),
                IconButton(
                  icon: const Icon(Icons.settings, size: 20),
                  tooltip: 'Pomodoro Settings',
                  onPressed: () => context.push('/pomodoro-settings'),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Close panel',
                  onPressed: widget.onClose,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Middle row: Countdown ring + session info
            Row(
              children: [
                const TimerCountdown(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getPhaseLabel(timerState.phase),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Session $sessionInCycle/$longBreakInterval',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Controls row
            const TimerControls(),

            const SizedBox(height: 4),

            // Daily stats + goal progress row
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Today: $dailyCount sessions | $focusText focused',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(child: GoalProgress()),
              ],
            ),

            // Expanded content: streak + expand toggle
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              const StreakCounter(),
              // Penguin placeholder for Plan 06
            ],

            // Expand/collapse chevron
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPhaseLabel(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.working:
        return 'Work';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
      case PomodoroPhase.idle:
        return 'Idle';
      case PomodoroPhase.ready:
        return 'Ready';
    }
  }
}
