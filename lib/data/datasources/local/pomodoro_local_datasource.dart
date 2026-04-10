import 'database_helper.dart';

/// Local data source for Pomodoro session CRUD operations using SQLite.
/// Follows the same patterns as TaskLocalDataSource.
class PomodoroLocalDatasource {
  final DatabaseHelper _dbHelper;

  PomodoroLocalDatasource({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  /// Insert a new pomodoro session into the database.
  /// Returns the auto-generated session ID.
  Future<int> insertSession(Map<String, dynamic> sessionMap) async {
    try {
      // Remove ID for auto-increment
      final map = Map<String, dynamic>.from(sessionMap);
      map.remove('id');

      final id = await _dbHelper.insert(
        DatabaseHelper.tablePomodoroSession,
        map,
      );

      if (id <= 0) {
        throw Exception('Failed to insert session: Invalid ID returned');
      }

      return id;
    } catch (e) {
      throw Exception('Failed to insert pomodoro session: $e');
    }
  }

  /// Get all sessions for a specific date.
  /// Queries by started_at range (start of day to end of day in UTC milliseconds).
  Future<List<Map<String, dynamic>>> getSessionsByDate(DateTime date) async {
    try {
      final localDate = DateTime(date.year, date.month, date.day);
      final startOfDay = localDate.toUtc().millisecondsSinceEpoch;
      final endOfDay =
          localDate.add(const Duration(days: 1)).toUtc().millisecondsSinceEpoch -
              1;

      return await _dbHelper.query(
        DatabaseHelper.tablePomodoroSession,
        where: 'started_at >= ? AND started_at <= ?',
        whereArgs: [startOfDay, endOfDay],
        orderBy: 'started_at ASC',
      );
    } catch (e) {
      throw Exception('Failed to get sessions by date: $e');
    }
  }

  /// Get all sessions for a specific task.
  Future<List<Map<String, dynamic>>> getSessionsByTaskId(int taskId) async {
    try {
      return await _dbHelper.query(
        DatabaseHelper.tablePomodoroSession,
        where: 'task_id = ?',
        whereArgs: [taskId],
        orderBy: 'started_at DESC',
      );
    } catch (e) {
      throw Exception('Failed to get sessions by task ID: $e');
    }
  }

  /// Get sessions within a date range (inclusive).
  Future<List<Map<String, dynamic>>> getSessionsInDateRange(
      DateTime start, DateTime end) async {
    try {
      final startMs = DateTime(start.year, start.month, start.day)
          .toUtc()
          .millisecondsSinceEpoch;
      final endMs = DateTime(end.year, end.month, end.day)
          .add(const Duration(days: 1))
          .toUtc()
          .millisecondsSinceEpoch -
          1;

      return await _dbHelper.query(
        DatabaseHelper.tablePomodoroSession,
        where: 'started_at >= ? AND started_at <= ?',
        whereArgs: [startMs, endMs],
        orderBy: 'started_at ASC',
      );
    } catch (e) {
      throw Exception('Failed to get sessions in date range: $e');
    }
  }

  /// Get total count of completed work sessions.
  Future<int> getTotalSessionCount() async {
    try {
      final results = await _dbHelper.rawQuery(
        "SELECT COUNT(*) as count FROM ${DatabaseHelper.tablePomodoroSession} "
        "WHERE session_type = 'work' AND is_completed = 1",
      );
      return results.first['count'] as int;
    } catch (e) {
      throw Exception('Failed to get total session count: $e');
    }
  }

  /// Get count of completed work sessions for a specific date.
  Future<int> getDailySessionCount(DateTime date) async {
    try {
      final localDate = DateTime(date.year, date.month, date.day);
      final startOfDay = localDate.toUtc().millisecondsSinceEpoch;
      final endOfDay =
          localDate.add(const Duration(days: 1)).toUtc().millisecondsSinceEpoch -
              1;

      final results = await _dbHelper.rawQuery(
        "SELECT COUNT(*) as count FROM ${DatabaseHelper.tablePomodoroSession} "
        "WHERE session_type = 'work' AND is_completed = 1 "
        "AND started_at >= ? AND started_at <= ?",
        [startOfDay, endOfDay],
      );
      return results.first['count'] as int;
    } catch (e) {
      throw Exception('Failed to get daily session count: $e');
    }
  }

  /// Calculate the current streak of consecutive days with completed work sessions.
  /// Counts backward from today.
  Future<int> getStreak() async {
    try {
      final results = await _dbHelper.rawQuery(
        "SELECT DISTINCT date(started_at/1000, 'unixepoch', 'localtime') as session_date "
        "FROM ${DatabaseHelper.tablePomodoroSession} "
        "WHERE session_type = 'work' AND is_completed = 1 "
        "ORDER BY session_date DESC",
      );

      if (results.isEmpty) return 0;

      int streak = 0;
      DateTime expectedDate = DateTime.now();
      expectedDate =
          DateTime(expectedDate.year, expectedDate.month, expectedDate.day);

      for (final row in results) {
        final dateStr = row['session_date'] as String;
        final parts = dateStr.split('-');
        final sessionDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        if (streak == 0) {
          // First entry: must be today or yesterday to count
          final diff = expectedDate.difference(sessionDate).inDays;
          if (diff > 1) return 0;
          expectedDate = sessionDate;
          streak = 1;
        } else {
          final diff = expectedDate.difference(sessionDate).inDays;
          if (diff == 1) {
            streak++;
            expectedDate = sessionDate;
          } else {
            break;
          }
        }
      }

      return streak;
    } catch (e) {
      throw Exception('Failed to get streak: $e');
    }
  }
}
