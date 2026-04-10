import 'package:flutter_test/flutter_test.dart';
import 'package:task_calendar_app/data/models/pomodoro_session_model.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_session.dart';

void main() {
  final testStartedAt = DateTime.utc(2026, 4, 10, 10, 0, 0);
  final testEndedAt = DateTime.utc(2026, 4, 10, 10, 25, 0);
  final testCreatedAt = DateTime.utc(2026, 4, 10, 9, 55, 0);

  final testSession = PomodoroSession(
    id: 1,
    taskId: 42,
    sessionType: 'work',
    startedAt: testStartedAt,
    endedAt: testEndedAt,
    durationSeconds: 1500,
    plannedDurationSeconds: 1500,
    isCompleted: true,
    createdAt: testCreatedAt,
  );

  final testMap = {
    'id': 1,
    'task_id': 42,
    'session_type': 'work',
    'started_at': testStartedAt.millisecondsSinceEpoch,
    'ended_at': testEndedAt.millisecondsSinceEpoch,
    'duration_seconds': 1500,
    'planned_duration_seconds': 1500,
    'is_completed': 1,
    'created_at': testCreatedAt.millisecondsSinceEpoch,
  };

  group('PomodoroSessionModel', () {
    test('fromMap correctly converts SQLite row map to PomodoroSession', () {
      final session = PomodoroSessionModel.fromMap(testMap);

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

    test('toMap correctly converts entity to SQLite row map', () {
      final map = PomodoroSessionModel.toMap(testSession);

      expect(map['id'], 1);
      expect(map['task_id'], 42);
      expect(map['session_type'], 'work');
      expect(map['started_at'], testStartedAt.millisecondsSinceEpoch);
      expect(map['ended_at'], testEndedAt.millisecondsSinceEpoch);
      expect(map['duration_seconds'], 1500);
      expect(map['planned_duration_seconds'], 1500);
      expect(map['is_completed'], 1);
      expect(map['created_at'], testCreatedAt.millisecondsSinceEpoch);
    });

    test('DateTime roundtrip preserves all fields', () {
      final map = PomodoroSessionModel.toMap(testSession);
      final roundtripped = PomodoroSessionModel.fromMap(map);

      expect(roundtripped, equals(testSession));
      expect(roundtripped.id, testSession.id);
      expect(roundtripped.taskId, testSession.taskId);
      expect(roundtripped.sessionType, testSession.sessionType);
      expect(roundtripped.startedAt, testSession.startedAt);
      expect(roundtripped.endedAt, testSession.endedAt);
      expect(roundtripped.durationSeconds, testSession.durationSeconds);
      expect(roundtripped.plannedDurationSeconds,
          testSession.plannedDurationSeconds);
      expect(roundtripped.isCompleted, testSession.isCompleted);
      expect(roundtripped.createdAt, testSession.createdAt);
    });

    test('isCompleted converts between bool and int 0/1', () {
      // Test completed = true -> 1
      final completedMap = PomodoroSessionModel.toMap(testSession);
      expect(completedMap['is_completed'], 1);

      // Test completed = false -> 0
      final incompleteSession = testSession.copyWith(isCompleted: false);
      final incompleteMap = PomodoroSessionModel.toMap(incompleteSession);
      expect(incompleteMap['is_completed'], 0);

      // Test 1 -> true
      final fromComplete = PomodoroSessionModel.fromMap({
        ...testMap,
        'is_completed': 1,
      });
      expect(fromComplete.isCompleted, true);

      // Test 0 -> false
      final fromIncomplete = PomodoroSessionModel.fromMap({
        ...testMap,
        'is_completed': 0,
      });
      expect(fromIncomplete.isCompleted, false);
    });
  });
}
