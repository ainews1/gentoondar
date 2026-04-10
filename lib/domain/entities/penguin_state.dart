import 'package:equatable/equatable.dart';

/// Companion penguin state tracking evolution and engagement.
/// The penguin evolves based on completed pomodoro sessions and
/// becomes stale if the user hasn't been active recently.
class PenguinState extends Equatable {
  const PenguinState({
    this.name = 'Tux',
    this.totalSessions = 0,
    this.currentStreak = 0,
    this.lastActivityDate,
  });

  /// Penguin companion name
  final String name;

  /// Total completed work sessions (lifetime)
  final int totalSessions;

  /// Consecutive days with at least one completed session
  final int currentStreak;

  /// Date of last completed session (null if never)
  final DateTime? lastActivityDate;

  /// Evolution stage derived from total sessions (advances every 5 sessions)
  int get evolutionStage => totalSessions ~/ 5;

  /// Seed for procedural generation based on total sessions
  int get seed => totalSessions.hashCode;

  /// Returns true if last activity was more than 3 days ago
  bool get isStale {
    if (lastActivityDate == null) return true;
    final daysSinceActivity =
        DateTime.now().toUtc().difference(lastActivityDate!).inDays;
    return daysSinceActivity > 3;
  }

  /// Create a copy with updated fields
  PenguinState copyWith({
    String? name,
    int? totalSessions,
    int? currentStreak,
    DateTime? lastActivityDate,
  }) {
    return PenguinState(
      name: name ?? this.name,
      totalSessions: totalSessions ?? this.totalSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  @override
  List<Object?> get props => [
        name,
        totalSessions,
        currentStreak,
        lastActivityDate,
      ];

  @override
  String toString() {
    return 'PenguinState(name: $name, sessions: $totalSessions, '
        'stage: $evolutionStage, streak: $currentStreak, stale: $isStale)';
  }
}
