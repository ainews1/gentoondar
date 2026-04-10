import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pomodoro_timer_providers.dart';

/// Circular countdown ring with MM:SS display and session type label.
/// Uses CustomPainter for the progress ring and Timer.periodic for ticking.
class TimerCountdown extends ConsumerStatefulWidget {
  const TimerCountdown({super.key});

  @override
  ConsumerState<TimerCountdown> createState() => _TimerCountdownState();
}

class _TimerCountdownState extends ConsumerState<TimerCountdown> {
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final notifier = ref.read(pomodoroTimerProvider.notifier);
      notifier.onTimerTick();
      setState(() {}); // trigger UI rebuild for countdown
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(pomodoroTimerProvider);
    final remaining = timerState.remainingTime;
    final totalSeconds = _getTotalSeconds(timerState);
    final progress = totalSeconds > 0
        ? remaining.inSeconds / totalSeconds
        : 0.0;
    final stateColor = _getStateColor(timerState);

    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Semantics(
      label: '${remaining.inMinutes} minutes ${remaining.inSeconds.remainder(60)} seconds remaining',
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring
            CustomPaint(
              size: const Size(100, 100),
              painter: _CountdownRingPainter(
                progress: progress.clamp(0.0, 1.0),
                fillColor: stateColor,
                backgroundColor:
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                strokeWidth: 8,
              ),
            ),
            // Center text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$minutes:$seconds',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 28,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  _getPhaseLabel(timerState.phase),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: 11,
                        color: stateColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalSeconds(PomodoroTimerState state) {
    // Estimate total from phase; we don't store total explicitly so use settings
    // This is used for ring progress calculation
    switch (state.phase) {
      case PomodoroPhase.working:
        return 25 * 60; // Will be overridden by actual settings
      case PomodoroPhase.shortBreak:
        return 5 * 60;
      case PomodoroPhase.longBreak:
        return 15 * 60;
      case PomodoroPhase.idle:
      case PomodoroPhase.ready:
        return 1; // Avoid division by zero
    }
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

  Color _getStateColor(PomodoroTimerState state) {
    if (state.isPaused) return const Color(0xFF9E9E9E);
    switch (state.phase) {
      case PomodoroPhase.working:
        return const Color(0xFFE53935);
      case PomodoroPhase.shortBreak:
        return const Color(0xFF43A047);
      case PomodoroPhase.longBreak:
        return const Color(0xFF1E88E5);
      case PomodoroPhase.idle:
      case PomodoroPhase.ready:
        return const Color(0xFF9E9E9E);
    }
  }
}

/// CustomPainter that draws a circular progress ring.
/// Fill sweeps counterclockwise from top (12 o'clock position).
class _CountdownRingPainter extends CustomPainter {
  final double progress;
  final Color fillColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CountdownRingPainter({
    required this.progress,
    required this.fillColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Fill ring (counterclockwise sweep)
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top (12 o'clock)
      -sweepAngle, // Counterclockwise
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_CountdownRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fillColor != fillColor;
  }
}
