import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pomodoro_timer_providers.dart';
import '../../providers/pomodoro_theme_providers.dart';
import 'timer_panel.dart';

/// Floating Action Button overlay for Pomodoro timer access (D-01, D-02, D-03).
/// Wraps a child widget in a Stack, positioning the FAB at bottom-right.
/// Tapping toggles the TimerPanel visibility with slide animation.
/// Listens to pomodoroMessageProvider to show SnackBar messages on session completion.
class PomodoroFab extends ConsumerStatefulWidget {
  final Widget child;

  const PomodoroFab({super.key, required this.child});

  @override
  ConsumerState<PomodoroFab> createState() => _PomodoroFabState();
}

class _PomodoroFabState extends ConsumerState<PomodoroFab>
    with SingleTickerProviderStateMixin {
  bool _showPanel = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Below screen
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _showPanel = !_showPanel;
    });
    if (_showPanel) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _hidePanel() {
    if (_showPanel) {
      setState(() => _showPanel = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(pomodoroTimerProvider);
    final isActive = timerState.isActive;
    final pomodoroTheme = ref.watch(currentPomodoroThemeProvider);

    // Listen for message provider to show SnackBar
    ref.listen<String?>(pomodoroMessageProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        // Reset message
        ref.read(pomodoroMessageProvider.notifier).state = null;
      }
    });

    final bottomPadding =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

    return Stack(
      children: [
        widget.child,

        // Timer panel (slides up from bottom)
        if (_showPanel)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding,
            child: SlideTransition(
              position: _slideAnimation,
              child: TimerPanel(
                onClose: _hidePanel,
              ),
            ),
          ),

        // FAB button
        Positioned(
          right: 16,
          bottom: bottomPadding + 16,
          child: Semantics(
            label:
                'Pomodoro Timer. ${isActive ? "Running" : "Stopped"}',
            child: Stack(
              children: [
                Container(
                  decoration: isActive
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: pomodoroTheme.glow.withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ],
                        )
                      : null,
                  child: FloatingActionButton(
                    heroTag: 'pomodoro_fab',
                    onPressed: _togglePanel,
                    tooltip: 'Pomodoro Timer',
                    child: const Icon(Icons.timer, size: 24),
                  ),
                ),
                // Active indicator badge
                if (isActive)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getBadgeColor(timerState.phase),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getBadgeColor(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.working:
        return const Color(0xFFE53935);
      case PomodoroPhase.shortBreak:
        return const Color(0xFF43A047);
      case PomodoroPhase.longBreak:
        return const Color(0xFF1E88E5);
      case PomodoroPhase.idle:
      case PomodoroPhase.ready:
        return Colors.grey;
    }
  }
}
