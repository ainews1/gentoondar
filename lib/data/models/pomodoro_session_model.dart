import 'package:task_calendar_app/domain/entities/pomodoro_session.dart';

/// Data model for PomodoroSession that handles SQLite serialization.
/// Converts between PomodoroSession entities and database row maps.
class PomodoroSessionModel {
  /// Convert a SQLite row map to a PomodoroSession entity.
  /// DateTimes are stored as milliseconds since epoch (int).
  /// isCompleted is stored as 0/1 integer in SQLite.
  static PomodoroSession fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'] as int,
      taskId: map['task_id'] as int,
      sessionType: map['session_type'] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        map['started_at'] as int,
        isUtc: true,
      ),
      endedAt: DateTime.fromMillisecondsSinceEpoch(
        map['ended_at'] as int,
        isUtc: true,
      ),
      durationSeconds: map['duration_seconds'] as int,
      plannedDurationSeconds: map['planned_duration_seconds'] as int,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
        isUtc: true,
      ),
    );
  }

  /// Convert a PomodoroSession entity to a SQLite row map.
  /// DateTimes are stored as milliseconds since epoch (int).
  /// isCompleted is stored as 0/1 integer.
  static Map<String, dynamic> toMap(PomodoroSession session) {
    return {
      'id': session.id,
      'task_id': session.taskId,
      'session_type': session.sessionType,
      'started_at': session.startedAt.millisecondsSinceEpoch,
      'ended_at': session.endedAt.millisecondsSinceEpoch,
      'duration_seconds': session.durationSeconds,
      'planned_duration_seconds': session.plannedDurationSeconds,
      'is_completed': session.isCompleted ? 1 : 0,
      'created_at': session.createdAt.millisecondsSinceEpoch,
    };
  }
}
