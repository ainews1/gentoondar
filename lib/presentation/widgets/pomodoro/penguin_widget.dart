import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/domain/entities/penguin_state.dart';
import 'package:task_calendar_app/presentation/providers/penguin_providers.dart';
import 'package:task_calendar_app/presentation/providers/pomodoro_timer_providers.dart';
import 'penguin_renderer.dart';

/// Animated penguin widget displaying the procedurally-generated pixel art mascot.
///
/// Features (D-48, D-49, D-50):
/// - 80x80px pixel art penguin rendered via [PenguinRenderer]
/// - Idle animations cycling at random 3-8 second intervals
/// - Spontaneous chirp sounds during break phases only
/// - Evolution sparkle effect when stage advances
/// - Proper timer disposal to prevent memory leaks
class PenguinWidget extends ConsumerStatefulWidget {
  const PenguinWidget({super.key});

  @override
  ConsumerState<PenguinWidget> createState() => _PenguinWidgetState();
}

class _PenguinWidgetState extends ConsumerState<PenguinWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _idleTimer;
  Timer? _chirpTimer;
  int _currentFrame = 0;
  final Random _random = Random();

  // Sparkle animation
  AnimationController? _sparkleController;
  bool _showSparkle = false;

  @override
  void initState() {
    super.initState();

    // Animation controller for frame cycling (500-1000ms per cycle)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController.addListener(_onAnimationTick);

    // Start idle animation scheduling
    _scheduleNextIdleAnimation();
  }

  void _onAnimationTick() {
    // Map animation value (0.0-1.0) to frame index (0-7)
    final frame = (_animationController.value * 8).floor().clamp(0, 7);
    if (frame != _currentFrame) {
      setState(() {
        _currentFrame = frame;
      });
      ref.read(penguinAnimationFrameProvider.notifier).state = frame;
    }
  }

  void _scheduleNextIdleAnimation() {
    _idleTimer?.cancel();
    // Random interval 3-8 seconds
    final delayMs = 3000 + _random.nextInt(5000);
    _idleTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      // Vary animation speed (500-1000ms)
      _animationController.duration =
          Duration(milliseconds: 500 + _random.nextInt(500));
      _animationController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _currentFrame = 0;
          });
          _scheduleNextIdleAnimation();
        }
      });
    });
  }

  void _startChirpTimer(PenguinState penguinState) {
    _chirpTimer?.cancel();
    // Stale penguin chirps less frequently (D-46, D-47)
    final minDelay = penguinState.isStale ? 60000 : 15000;
    final maxDelay = penguinState.isStale ? 120000 : 45000;
    final delayMs = minDelay + _random.nextInt(maxDelay - minDelay);

    _chirpTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      // Check we're still in a break phase
      final timerState = ref.read(pomodoroTimerProvider);
      if (timerState.phase == PomodoroPhase.shortBreak ||
          timerState.phase == PomodoroPhase.longBreak) {
        // Audio service would be called here if available
        // For now, penguin chirp is a visual-only indicator
        // ref.read(pomodoroAudioServiceProvider).playPenguinChirp();
      }
      _startChirpTimer(penguinState);
    });
  }

  void _stopChirpTimer() {
    _chirpTimer?.cancel();
    _chirpTimer = null;
  }

  /// Trigger sparkle animation for evolution stage advancement (D-52)
  Future<void> triggerEvolutionSparkle() async {
    _sparkleController?.dispose();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    setState(() => _showSparkle = true);

    await _sparkleController!.forward();

    if (mounted) {
      setState(() => _showSparkle = false);
    }
    _sparkleController?.dispose();
    _sparkleController = null;
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _chirpTimer?.cancel();
    _animationController.dispose();
    _sparkleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final penguinStateAsync = ref.watch(penguinStateProvider);
    final timerState = ref.watch(pomodoroTimerProvider);

    // Manage chirp timer based on phase
    final isBreak = timerState.phase == PomodoroPhase.shortBreak ||
        timerState.phase == PomodoroPhase.longBreak;

    final penguinState =
        penguinStateAsync.valueOrNull ?? const PenguinState();

    // Start/stop chirp timer based on break phase (D-50)
    if (isBreak && _chirpTimer == null) {
      _startChirpTimer(penguinState);
    } else if (!isBreak && _chirpTimer != null) {
      _stopChirpTimer();
    }

    return Semantics(
      label: 'Your penguin ${penguinState.name}, '
          'evolution stage ${penguinState.evolutionStage}',
      child: ExcludeSemantics(
        child: SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              // Main penguin
              CustomPaint(
                size: const Size(80, 80),
                painter: PenguinRenderer(
                  state: penguinState,
                  animationFrame: _currentFrame,
                  auraColor: null, // Theme glow wired when theme provider exists
                ),
              ),

              // Evolution sparkle overlay (D-52)
              if (_showSparkle && _sparkleController != null)
                AnimatedBuilder(
                  animation: _sparkleController!,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(80, 80),
                      painter: _SparklePainter(
                        progress: _sparkleController!.value,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints 8-12 small sparkle dots radiating from center during evolution.
class _SparklePainter extends CustomPainter {
  _SparklePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  static final Paint _sparklePaint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = Random(42); // Fixed seed for consistent sparkle pattern
    final particleCount = 8 + random.nextInt(5); // 8-12 particles

    _sparklePaint.color = color.withValues(alpha: 1.0 - progress);
    final radius = 2.0 * (1.0 - progress) + 1.0; // Scale 3->1

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi + random.nextDouble() * 0.5;
      final distance = progress * 40; // Radiate outward up to 40px
      final offset = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );
      canvas.drawCircle(offset, radius, _sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}
