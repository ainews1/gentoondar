import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_session.dart';
import 'package:task_calendar_app/domain/usecases/complete_pomodoro_session.dart';
import 'pomodoro_session_providers.dart';
import 'pomodoro_settings_providers.dart';

// =============================================================================
// Timer Phase Enum
// =============================================================================

/// Phases of the Pomodoro timer cycle
enum PomodoroPhase {
  /// No timer active, waiting for user action
  idle,

  /// Task selected, ready to start work
  ready,

  /// Work session in progress
  working,

  /// Short break in progress
  shortBreak,

  /// Long break in progress (after longBreakInterval work sessions)
  longBreak,
}

// =============================================================================
// Timer State
// =============================================================================

/// Immutable state for the Pomodoro timer.
/// Uses wall-clock DateTime for background resilience (D-12):
/// when app resumes, remainingTime recalculates from targetEndTime vs now.
class PomodoroTimerState extends Equatable {
  /// Current phase of the timer cycle
  final PomodoroPhase phase;

  /// Whether the timer is paused (D-15: no time limit on pause)
  final bool isPaused;

  /// Wall-clock time when the current session ends
  final DateTime? targetEndTime;

  /// When the current pause started
  final DateTime? pausedAt;

  /// When the current session began (for saving session data)
  final DateTime? sessionStartedAt;

  /// Number of completed work sessions in current cycle
  final int completedSessions;

  /// ID of the linked task (D-10: can switch mid-session)
  final int? linkedTaskId;

  /// Accumulated pause time for this session
  final Duration totalPausedDuration;

  const PomodoroTimerState({
    this.phase = PomodoroPhase.idle,
    this.isPaused = false,
    this.targetEndTime,
    this.pausedAt,
    this.sessionStartedAt,
    this.completedSessions = 0,
    this.linkedTaskId,
    this.totalPausedDuration = Duration.zero,
  });

  /// Remaining time until session ends.
  /// When paused, freezes at the moment of pause.
  /// When not paused, dynamically recalculates from wall-clock (background resilient).
  Duration get remainingTime {
    if (targetEndTime == null) return Duration.zero;
    if (isPaused && pausedAt != null) {
      return targetEndTime!.difference(pausedAt!);
    }
    final remaining = targetEndTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Whether the timer is actively running (working or on break)
  bool get isActive =>
      phase == PomodoroPhase.working ||
      phase == PomodoroPhase.shortBreak ||
      phase == PomodoroPhase.longBreak;

  /// Whether the current active session has completed (time ran out)
  bool get isCompleted =>
      isActive && !isPaused && remainingTime == Duration.zero;

  /// Create a copy with updated fields
  PomodoroTimerState copyWith({
    PomodoroPhase? phase,
    bool? isPaused,
    DateTime? targetEndTime,
    DateTime? pausedAt,
    DateTime? sessionStartedAt,
    int? completedSessions,
    int? linkedTaskId,
    Duration? totalPausedDuration,
    bool clearTargetEndTime = false,
    bool clearPausedAt = false,
    bool clearSessionStartedAt = false,
    bool clearLinkedTaskId = false,
  }) {
    return PomodoroTimerState(
      phase: phase ?? this.phase,
      isPaused: isPaused ?? this.isPaused,
      targetEndTime:
          clearTargetEndTime ? null : (targetEndTime ?? this.targetEndTime),
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      sessionStartedAt: clearSessionStartedAt
          ? null
          : (sessionStartedAt ?? this.sessionStartedAt),
      completedSessions: completedSessions ?? this.completedSessions,
      linkedTaskId:
          clearLinkedTaskId ? null : (linkedTaskId ?? this.linkedTaskId),
      totalPausedDuration: totalPausedDuration ?? this.totalPausedDuration,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        isPaused,
        targetEndTime,
        pausedAt,
        sessionStartedAt,
        completedSessions,
        linkedTaskId,
        totalPausedDuration,
      ];

  @override
  String toString() {
    return 'PomodoroTimerState(phase: $phase, isPaused: $isPaused, '
        'remaining: ${remainingTime.inSeconds}s, sessions: $completedSessions, '
        'taskId: $linkedTaskId)';
  }
}

// =============================================================================
// Timer Notifier (NOT autoDispose — survives tab switches per Research pitfall 5)
// =============================================================================

/// Core Pomodoro timer state machine.
/// Manages state transitions: IDLE -> READY -> WORK -> BREAK -> WORK cycle.
/// Uses wall-clock DateTime for background resilience (D-12).
/// State is in-memory only — cold restart resets everything (D-13).
class PomodoroTimerNotifier extends Notifier<PomodoroTimerState> {
  /// In-memory session tracking for save on completion
  PomodoroSession? _currentSession;

  @override
  PomodoroTimerState build() {
    return const PomodoroTimerState();
  }

  /// Select a task to link with the timer (D-10).
  /// Transitions from idle to ready.
  void selectTask(int taskId) {
    if (state.phase == PomodoroPhase.idle) {
      state = state.copyWith(
        phase: PomodoroPhase.ready,
        linkedTaskId: taskId,
      );
    } else {
      // If already in a session, just update the linked task
      state = state.copyWith(linkedTaskId: taskId);
    }
  }

  /// Start a work session.
  /// Reads settings for work duration, sets targetEndTime using wall-clock.
  void startWork() {
    final settingsAsync = ref.read(pomodoroSettingsProvider);
    final settings = settingsAsync.valueOrNull;
    if (settings == null) return;

    final now = DateTime.now();
    final workDuration = Duration(minutes: settings.workDurationMinutes);

    // Create in-memory session tracking
    _currentSession = PomodoroSession.create(
      taskId: state.linkedTaskId ?? 0,
      sessionType: 'work',
      startedAt: now,
      endedAt: now, // Placeholder
      durationSeconds: 0,
      plannedDurationSeconds: workDuration.inSeconds,
      isCompleted: false,
    );

    state = state.copyWith(
      phase: PomodoroPhase.working,
      isPaused: false,
      targetEndTime: now.add(workDuration),
      sessionStartedAt: now,
      totalPausedDuration: Duration.zero,
      clearPausedAt: true,
    );
  }

  /// Pause the timer (D-15: no time limit on pause).
  void pause() {
    if (!state.isActive || state.isPaused) return;

    state = state.copyWith(
      isPaused: true,
      pausedAt: DateTime.now(),
    );
  }

  /// Resume the timer after pause.
  /// Adjusts targetEndTime by the pause duration to maintain accurate remaining time.
  void resume() {
    if (!state.isPaused || state.pausedAt == null) return;

    final now = DateTime.now();
    final pauseDuration = now.difference(state.pausedAt!);
    final newTarget = state.targetEndTime!.add(pauseDuration);

    state = state.copyWith(
      isPaused: false,
      targetEndTime: newTarget,
      totalPausedDuration: state.totalPausedDuration + pauseDuration,
      clearPausedAt: true,
    );
  }

  /// Skip the current break and move to ready for next work session (D-14).
  void skipBreak() {
    if (state.phase != PomodoroPhase.shortBreak &&
        state.phase != PomodoroPhase.longBreak) {
      return;
    }

    state = state.copyWith(
      phase: PomodoroPhase.ready,
      isPaused: false,
      clearTargetEndTime: true,
      clearPausedAt: true,
      clearSessionStartedAt: true,
      totalPausedDuration: Duration.zero,
    );
  }

  /// Stop the timer and save a partial session.
  /// Returns to idle state.
  Future<void> stop() async {
    if (_currentSession != null && state.sessionStartedAt != null) {
      await _saveSession(isCompleted: false);
    }

    _currentSession = null;
    state = const PomodoroTimerState();
  }

  /// Switch the linked task mid-session without stopping the timer (D-10).
  void switchTask(int newTaskId) {
    state = state.copyWith(linkedTaskId: newTaskId);
  }

  /// Called by UI timer on each tick.
  /// Checks if time has run out and triggers session completion.
  Future<void> onTimerTick() async {
    if (!state.isActive || state.isPaused) return;

    if (state.remainingTime <= Duration.zero) {
      await _onSessionComplete();
    }
  }

  /// Handle task completion — auto-stop timer if linked task completes (D-11).
  Future<void> onTaskCompleted(int taskId) async {
    if (state.linkedTaskId == taskId && state.isActive) {
      await stop();
      ref.read(pomodoroMessageProvider.notifier).state =
          'Timer stopped — task completed';
    }
  }

  /// Reset everything to idle state.
  void reset() {
    _currentSession = null;
    state = const PomodoroTimerState();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Handle session completion: save, increment counter, transition to next phase.
  Future<void> _onSessionComplete() async {
    final wasWork = state.phase == PomodoroPhase.working;

    // Save completed session
    await _saveSession(isCompleted: true);
    _currentSession = null;

    if (wasWork) {
      final newCount = state.completedSessions + 1;
      final settings = ref.read(pomodoroSettingsProvider).valueOrNull;
      final longBreakInterval = settings?.longBreakInterval ?? 4;

      // Determine break type
      final isLongBreak = newCount % longBreakInterval == 0;
      final nextPhase =
          isLongBreak ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;

      // Determine break duration
      final breakMinutes = isLongBreak
          ? (settings?.longBreakMinutes ?? 15)
          : (settings?.shortBreakMinutes ?? 5);

      final shouldAutoStart = settings?.autoStartBreaks ?? false;
      final now = DateTime.now();

      // Create break session tracking
      _currentSession = PomodoroSession.create(
        taskId: state.linkedTaskId ?? 0,
        sessionType: isLongBreak ? 'long_break' : 'short_break',
        startedAt: now,
        endedAt: now,
        durationSeconds: 0,
        plannedDurationSeconds: breakMinutes * 60,
        isCompleted: false,
      );

      if (shouldAutoStart) {
        state = state.copyWith(
          phase: nextPhase,
          completedSessions: newCount,
          targetEndTime: now.add(Duration(minutes: breakMinutes)),
          sessionStartedAt: now,
          isPaused: false,
          totalPausedDuration: Duration.zero,
          clearPausedAt: true,
        );
      } else {
        state = state.copyWith(
          phase: nextPhase,
          completedSessions: newCount,
          clearTargetEndTime: true,
          clearSessionStartedAt: true,
          isPaused: false,
          totalPausedDuration: Duration.zero,
          clearPausedAt: true,
        );
      }

      // Notify UI
      ref.read(pomodoroMessageProvider.notifier).state =
          'Work session #$newCount complete! Time for a ${isLongBreak ? "long" : "short"} break.';

      // Invalidate session count providers
      ref.invalidate(dailyPomodoroCountProvider);
      ref.invalidate(dailyFocusMinutesProvider);
    } else {
      // After break, prepare for next work session
      final settings = ref.read(pomodoroSettingsProvider).valueOrNull;
      final shouldAutoStart = settings?.autoStartWork ?? false;

      if (shouldAutoStart) {
        startWork();
      } else {
        state = state.copyWith(
          phase: PomodoroPhase.ready,
          clearTargetEndTime: true,
          clearPausedAt: true,
          clearSessionStartedAt: true,
          totalPausedDuration: Duration.zero,
        );
      }

      ref.read(pomodoroMessageProvider.notifier).state =
          'Break complete! Ready for next work session.';
    }
  }

  /// Save the current session via CompletePomodoroSession use case.
  Future<void> _saveSession({required bool isCompleted}) async {
    if (_currentSession == null) return;

    final useCase = ref.read(completePomodoroSessionUseCaseProvider);
    await useCase(CompletePomodoroSessionParams(
      session: _currentSession!,
      isCompleted: isCompleted,
    ));
  }
}

// =============================================================================
// Provider Declarations
// =============================================================================

/// Main timer state provider.
/// NOT autoDispose — timer must survive tab switches (Research pitfall 5).
final pomodoroTimerProvider =
    NotifierProvider<PomodoroTimerNotifier, PomodoroTimerState>(
  () => PomodoroTimerNotifier(),
);

/// Message provider for timer notifications (SnackBar messages).
/// UI watches this and shows SnackBar when non-null, then clears it.
final pomodoroMessageProvider = StateProvider<String?>((ref) => null);
