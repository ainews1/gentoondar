import 'package:equatable/equatable.dart';

/// Pomodoro session entity representing a single work/break interval.
/// Tracks actual elapsed time vs planned duration for analytics.
class PomodoroSession extends Equatable {
  const PomodoroSession({
    required this.id,
    required this.taskId,
    required this.sessionType,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.plannedDurationSeconds,
    this.isCompleted = true,
    required this.createdAt,
  })  : assert(
          sessionType == 'work' ||
              sessionType == 'short_break' ||
              sessionType == 'long_break',
          'sessionType must be work, short_break, or long_break',
        );

  /// Unique identifier (auto-increment primary key)
  final int id;

  /// Foreign key to the tasks table
  final int taskId;

  /// Session type: 'work', 'short_break', or 'long_break'
  final String sessionType;

  /// When the session started (UTC)
  final DateTime startedAt;

  /// When the session ended (UTC)
  final DateTime endedAt;

  /// Actual elapsed duration in seconds
  final int durationSeconds;

  /// Configured/planned duration in seconds
  final int plannedDurationSeconds;

  /// Whether the full session was completed (false = partial/interrupted)
  final bool isCompleted;

  /// Creation timestamp (UTC)
  final DateTime createdAt;

  /// Create a new session with createdAt set to current UTC time
  factory PomodoroSession.create({
    int id = 0,
    required int taskId,
    required String sessionType,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationSeconds,
    required int plannedDurationSeconds,
    bool isCompleted = true,
  }) {
    return PomodoroSession(
      id: id,
      taskId: taskId,
      sessionType: sessionType,
      startedAt: startedAt.toUtc(),
      endedAt: endedAt.toUtc(),
      durationSeconds: durationSeconds,
      plannedDurationSeconds: plannedDurationSeconds,
      isCompleted: isCompleted,
      createdAt: DateTime.now().toUtc(),
    );
  }

  /// Create a copy with updated fields
  PomodoroSession copyWith({
    int? id,
    int? taskId,
    String? sessionType,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    int? plannedDurationSeconds,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      sessionType: sessionType ?? this.sessionType,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      plannedDurationSeconds:
          plannedDurationSeconds ?? this.plannedDurationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        sessionType,
        startedAt,
        endedAt,
        durationSeconds,
        plannedDurationSeconds,
        isCompleted,
        createdAt,
      ];

  @override
  String toString() {
    return 'PomodoroSession(id: $id, taskId: $taskId, type: $sessionType, '
        'duration: ${durationSeconds}s, completed: $isCompleted)';
  }
}
