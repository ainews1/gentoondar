import 'package:flutter_test/flutter_test.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_session.dart';

void main() {
  final testStartedAt = DateTime.utc(2026, 4, 10, 10, 0, 0);
  final testEndedAt = DateTime.utc(2026, 4, 10, 10, 25, 0);
  final testCreatedAt = DateTime.utc(2026, 4, 10, 9, 55, 0);

  PomodoroSession createTestSession({
    int id = 1,
    int taskId = 42,
    String sessionType = 'work',
    bool isCompleted = true,
  }) {
    return PomodoroSession(
      id: id,
      taskId: taskId,
      sessionType: sessionType,
      startedAt: testStartedAt,
      endedAt: testEndedAt,
      durationSeconds: 1500,
      plannedDurationSeconds: 1500,
      isCompleted: isCompleted,
      createdAt: testCreatedAt,
    );
  }

  group('PomodoroSession', () {
    test('constructs with all required fields', () {
      final session = createTestSession();

      expect(session.id, 1);
      expect(session.taskId, 42);
      expect(session.sessionType, 'work');
      expect(session.startedAt, testStartedAt);
      expect(session.endedAt, testEndedAt);
      expect(session.durationSeconds, 1500);
      expect(session.plannedDurationSeconds, 1500);
      expect(session.isCompleted, true);
      expect(session.createdAt, testCreatedAt);
    });

    test('copyWith preserves unchanged fields and updates changed ones', () {
      final session = createTestSession();
      final copied = session.copyWith(taskId: 99, isCompleted: false);

      expect(copied.id, session.id);
      expect(copied.taskId, 99);
      expect(copied.sessionType, session.sessionType);
      expect(copied.startedAt, session.startedAt);
      expect(copied.endedAt, session.endedAt);
      expect(copied.durationSeconds, session.durationSeconds);
      expect(copied.plannedDurationSeconds, session.plannedDurationSeconds);
      expect(copied.isCompleted, false);
      expect(copied.createdAt, session.createdAt);
    });

    test('Equatable: two identical sessions are equal', () {
      final session1 = createTestSession();
      final session2 = createTestSession();

      expect(session1, equals(session2));
      expect(session1.hashCode, session2.hashCode);
    });

    test('Equatable: different sessions are not equal', () {
      final session1 = createTestSession(id: 1);
      final session2 = createTestSession(id: 2);

      expect(session1, isNot(equals(session2)));
    });

    test('PomodoroSession.create() sets createdAt to UTC now', () {
      final before = DateTime.now().toUtc();
      final session = PomodoroSession.create(
        taskId: 1,
        sessionType: 'work',
        startedAt: testStartedAt,
        endedAt: testEndedAt,
        durationSeconds: 1500,
        plannedDurationSeconds: 1500,
      );
      final after = DateTime.now().toUtc();

      expect(session.createdAt.isUtc, true);
      expect(
        session.createdAt.isAfter(before) ||
            session.createdAt.isAtSameMomentAs(before),
        true,
      );
      expect(
        session.createdAt.isBefore(after) ||
            session.createdAt.isAtSameMomentAs(after),
        true,
      );
    });

    test('sessionType accepts work, short_break, and long_break', () {
      expect(() => createTestSession(sessionType: 'work'), returnsNormally);
      expect(
          () => createTestSession(sessionType: 'short_break'), returnsNormally);
      expect(
          () => createTestSession(sessionType: 'long_break'), returnsNormally);
    });

    test('toString returns readable representation', () {
      final session = createTestSession();
      final str = session.toString();

      expect(str, contains('PomodoroSession'));
      expect(str, contains('id: 1'));
      expect(str, contains('taskId: 42'));
      expect(str, contains('type: work'));
    });
  });
}
