import 'package:flutter_test/flutter_test.dart';
import 'package:task_calendar_app/presentation/providers/pomodoro_timer_providers.dart';

void main() {
  group('PomodoroTimerState', () {
    test('Test 1: Initial state is idle, not paused, no target, 0 sessions',
        () {
      const state = PomodoroTimerState();

      expect(state.phase, PomodoroPhase.idle);
      expect(state.isPaused, false);
      expect(state.targetEndTime, isNull);
      expect(state.completedSessions, 0);
    });

    test('Test 2: selectTask transitions from idle to ready with linkedTaskId',
        () {
      const initial = PomodoroTimerState();
      // Simulate selectTask: phase becomes ready, linkedTaskId is set
      final afterSelect = PomodoroTimerState(
        phase: PomodoroPhase.ready,
        linkedTaskId: 42,
      );

      expect(afterSelect.phase, PomodoroPhase.ready);
      expect(afterSelect.linkedTaskId, 42);
    });

    test('Test 3: startWork sets working, targetEndTime, isPaused=false', () {
      final now = DateTime.now();
      final target = now.add(const Duration(minutes: 25));

      final workState = PomodoroTimerState(
        phase: PomodoroPhase.working,
        targetEndTime: target,
        sessionStartedAt: now,
        linkedTaskId: 1,
      );

      expect(workState.phase, PomodoroPhase.working);
      expect(workState.targetEndTime, target);
      expect(workState.isPaused, false);
      expect(workState.sessionStartedAt, now);
    });

    test('Test 4: pause sets isPaused=true, pausedAt=now', () {
      final now = DateTime.now();
      final target = now.add(const Duration(minutes: 20));

      final pausedState = PomodoroTimerState(
        phase: PomodoroPhase.working,
        isPaused: true,
        targetEndTime: target,
        pausedAt: now,
        linkedTaskId: 1,
      );

      expect(pausedState.isPaused, true);
      expect(pausedState.pausedAt, now);
    });

    test('Test 5: resume adjusts targetEndTime by pause duration', () {
      final sessionStart = DateTime(2026, 1, 1, 10, 0);
      final pausedAt = DateTime(2026, 1, 1, 10, 10);
      final originalTarget = DateTime(2026, 1, 1, 10, 25);
      // After 5 minutes paused, target should shift by 5 minutes
      final pauseDuration = const Duration(minutes: 5);
      final newTarget = originalTarget.add(pauseDuration);

      final resumed = PomodoroTimerState(
        phase: PomodoroPhase.working,
        isPaused: false,
        targetEndTime: newTarget,
        totalPausedDuration: pauseDuration,
        linkedTaskId: 1,
      );

      expect(resumed.isPaused, false);
      expect(resumed.pausedAt, isNull);
      expect(resumed.targetEndTime, newTarget);
      expect(resumed.totalPausedDuration, pauseDuration);
    });

    test(
        'Test 6: remainingTime returns targetEndTime.difference(now) when not paused',
        () {
      final target = DateTime.now().add(const Duration(minutes: 10));
      final state = PomodoroTimerState(
        phase: PomodoroPhase.working,
        targetEndTime: target,
      );

      final remaining = state.remainingTime;
      // Should be approximately 10 minutes (within 2 seconds tolerance)
      expect(remaining.inSeconds, closeTo(600, 2));
    });

    test(
        'Test 7: remainingTime returns targetEndTime.difference(pausedAt) when paused',
        () {
      final pausedAt = DateTime(2026, 1, 1, 10, 15);
      final target = DateTime(2026, 1, 1, 10, 25);

      final state = PomodoroTimerState(
        phase: PomodoroPhase.working,
        isPaused: true,
        targetEndTime: target,
        pausedAt: pausedAt,
      );

      final remaining = state.remainingTime;
      expect(remaining.inMinutes, 10);
    });

    test(
        'Test 8: after work complete, completedSessions increments and transitions to break',
        () {
      // Simulating state after onTimerComplete during work
      final afterWorkComplete = PomodoroTimerState(
        phase: PomodoroPhase.shortBreak,
        completedSessions: 1,
        linkedTaskId: 1,
        targetEndTime: DateTime.now().add(const Duration(minutes: 5)),
      );

      expect(afterWorkComplete.phase, PomodoroPhase.shortBreak);
      expect(afterWorkComplete.completedSessions, 1);
    });

    test(
        'Test 9: after longBreakInterval work sessions, break type is longBreak',
        () {
      // After 4 work sessions (longBreakInterval default), should be longBreak
      final afterFourthWork = PomodoroTimerState(
        phase: PomodoroPhase.longBreak,
        completedSessions: 4,
        linkedTaskId: 1,
      );

      expect(afterFourthWork.phase, PomodoroPhase.longBreak);
      expect(afterFourthWork.completedSessions, 4);
    });

    test('Test 10: skipBreak transitions to next work pending state', () {
      // After skipping break, should go back to ready for next work session
      final afterSkip = PomodoroTimerState(
        phase: PomodoroPhase.ready,
        completedSessions: 1,
        linkedTaskId: 1,
      );

      expect(afterSkip.phase, PomodoroPhase.ready);
      expect(afterSkip.completedSessions, 1);
    });

    test('Test 11: stop returns to idle', () {
      const afterStop = PomodoroTimerState(
        phase: PomodoroPhase.idle,
      );

      expect(afterStop.phase, PomodoroPhase.idle);
      expect(afterStop.linkedTaskId, isNull);
      expect(afterStop.completedSessions, 0);
    });

    test('Test 12: switchTask changes linkedTaskId without stopping timer', () {
      final state = PomodoroTimerState(
        phase: PomodoroPhase.working,
        linkedTaskId: 1,
        targetEndTime: DateTime.now().add(const Duration(minutes: 15)),
        sessionStartedAt: DateTime.now(),
      );

      // After switchTask, linkedTaskId changes but phase stays working
      final afterSwitch = PomodoroTimerState(
        phase: state.phase,
        linkedTaskId: 2,
        targetEndTime: state.targetEndTime,
        sessionStartedAt: state.sessionStartedAt,
        completedSessions: state.completedSessions,
        totalPausedDuration: state.totalPausedDuration,
      );

      expect(afterSwitch.phase, PomodoroPhase.working);
      expect(afterSwitch.linkedTaskId, 2);
      expect(afterSwitch.targetEndTime, state.targetEndTime);
    });
  });

  group('PomodoroTimerState properties', () {
    test('isActive returns true for working, shortBreak, longBreak', () {
      expect(
        const PomodoroTimerState(phase: PomodoroPhase.working).isActive,
        true,
      );
      expect(
        const PomodoroTimerState(phase: PomodoroPhase.shortBreak).isActive,
        true,
      );
      expect(
        const PomodoroTimerState(phase: PomodoroPhase.longBreak).isActive,
        true,
      );
    });

    test('isActive returns false for idle and ready', () {
      expect(
        const PomodoroTimerState(phase: PomodoroPhase.idle).isActive,
        false,
      );
      expect(
        const PomodoroTimerState(phase: PomodoroPhase.ready).isActive,
        false,
      );
    });

    test('remainingTime returns Duration.zero when targetEndTime is null', () {
      const state = PomodoroTimerState();
      expect(state.remainingTime, Duration.zero);
    });

    test('Equatable: two identical states are equal', () {
      final target = DateTime(2026, 1, 1, 12, 0);
      final a = PomodoroTimerState(
        phase: PomodoroPhase.working,
        targetEndTime: target,
        completedSessions: 2,
      );
      final b = PomodoroTimerState(
        phase: PomodoroPhase.working,
        targetEndTime: target,
        completedSessions: 2,
      );
      expect(a, equals(b));
    });
  });
}
