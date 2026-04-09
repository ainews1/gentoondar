import '../../../data/models/task_model.dart';
import 'database_helper.dart';

/// Local data source for task CRUD operations using SQLite
class TaskLocalDataSource {
  final DatabaseHelper _databaseHelper;

  TaskLocalDataSource({DatabaseHelper? databaseHelper}) 
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// Insert a new task into the database
  /// Returns the auto-generated task ID
  Future<int> insertTask(TaskModel task) async {
    final taskMap = task.toJson();
    // Remove ID for auto-increment
    taskMap.remove('id');
    
    try {
      final id = await _databaseHelper.insert(
        DatabaseHelper.tableTask, 
        taskMap,
      );
      
      if (id <= 0) {
        throw Exception('Failed to insert task: Invalid ID returned');
      }
      
      return id;
    } catch (e) {
      throw Exception('Failed to insert task: $e');
    }
  }

  /// Update an existing task in the database
  /// Returns the number of rows affected (should be 1 for success)
  Future<int> updateTask(TaskModel task) async {
    try {
      final rowsAffected = await _databaseHelper.update(
        DatabaseHelper.tableTask,
        task.toJson(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Task not found or update failed');
      }
      
      return rowsAffected;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Delete a task from the database
  /// Returns the number of rows affected (should be 1 for success)
  Future<int> deleteTask(int id) async {
    try {
      final rowsAffected = await _databaseHelper.delete(
        DatabaseHelper.tableTask,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Task not found or delete failed');
      }
      
      return rowsAffected;
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Get a task by ID
  /// Returns null if task not found
  Future<TaskModel?> getTaskById(int id) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseHelper.tableTask,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      return TaskModel.fromJson(results.first);
    } catch (e) {
      throw Exception('Failed to get task by ID: $e');
    }
  }

  /// Get all tasks for a specific date (in local timezone)
  /// Date parameter should be in local timezone, will be converted for SQL query
  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    try {
      // Convert date to start and end of day in UTC milliseconds for database query
      final localDate = DateTime(date.year, date.month, date.day);
      final startOfDay = localDate.millisecondsSinceEpoch;
      final endOfDay = localDate.add(Duration(days: 1)).millisecondsSinceEpoch - 1;
      
      final results = await _databaseHelper.query(
        DatabaseHelper.tableTask,
        where: 'start_time >= ? AND start_time <= ?',
        whereArgs: [startOfDay, endOfDay],
        orderBy: 'start_time ASC',
      );
      
      return results.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get tasks for date: $e');
    }
  }

  /// Get tasks within a date range (inclusive)
  /// Optimized for calendar month/week views
  Future<List<TaskModel>> getTasksForDateRange(
    DateTime startDate, 
    DateTime endDate,
  ) async {
    try {
      // Convert to start of startDate and end of endDate
      final start = DateTime(startDate.year, startDate.month, startDate.day)
          .millisecondsSinceEpoch;
      final end = DateTime(endDate.year, endDate.month, endDate.day)
          .add(Duration(days: 1))
          .millisecondsSinceEpoch - 1;
      
      final results = await _databaseHelper.query(
        DatabaseHelper.tableTask,
        where: 'start_time >= ? AND start_time <= ?',
        whereArgs: [start, end],
        orderBy: 'start_time ASC',
      );
      
      return results.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get tasks for date range: $e');
    }
  }

  /// Get all tasks in the database
  /// Use with caution - can be slow with large datasets
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final results = await _databaseHelper.query(
        DatabaseHelper.tableTask,
        orderBy: 'start_time DESC',
      );
      
      return results.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get all tasks: $e');
    }
  }

  /// Get tasks filtered by completion status
  Future<List<TaskModel>> getTasksByCompletionStatus(bool isCompleted) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseHelper.tableTask,
        where: 'is_completed = ?',
        whereArgs: [isCompleted ? 1 : 0],
        orderBy: 'start_time DESC',
      );
      
      return results.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get tasks by completion status: $e');
    }
  }

  /// Search tasks by title or description
  /// Case-insensitive search using LIKE operator
  Future<List<TaskModel>> searchTasks(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      return [];
    }
    
    try {
      final term = '%${searchTerm.trim()}%';
      final results = await _databaseHelper.query(
        DatabaseHelper.tableTask,
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: [term, term],
        orderBy: 'start_time DESC',
      );
      
      return results.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search tasks: $e');
    }
  }

  /// Get task count for a specific date (useful for calendar indicators)
  Future<int> getTaskCountForDate(DateTime date) async {
    try {
      final localDate = DateTime(date.year, date.month, date.day);
      final startOfDay = localDate.millisecondsSinceEpoch;
      final endOfDay = localDate.add(Duration(days: 1)).millisecondsSinceEpoch - 1;
      
      final results = await _databaseHelper.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableTask} WHERE start_time >= ? AND start_time <= ?',
        [startOfDay, endOfDay],
      );
      
      return results.first['count'] as int;
    } catch (e) {
      throw Exception('Failed to get task count for date: $e');
    }
  }

  /// Get busy day statistics (for productivity analytics)
  Future<Map<String, int>> getBusyDayStats(DateTime startDate, DateTime endDate) async {
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day)
          .millisecondsSinceEpoch;
      final end = DateTime(endDate.year, endDate.month, endDate.day)
          .add(Duration(days: 1))
          .millisecondsSinceEpoch - 1;
      
      final results = await _databaseHelper.rawQuery('''
        SELECT 
          date(start_time/1000, 'unixepoch', 'localtime') as date,
          COUNT(*) as task_count,
          SUM(duration_minutes) as total_minutes
        FROM ${DatabaseHelper.tableTask} 
        WHERE start_time >= ? AND start_time <= ?
        GROUP BY date
        ORDER BY date
      ''', [start, end]);
      
      Map<String, int> stats = {};
      for (var row in results) {
        final date = row['date'] as String;
        final count = row['task_count'] as int;
        final minutes = row['total_minutes'] as int;
        
        stats['${date}_count'] = count;
        stats['${date}_minutes'] = minutes;
      }
      
      return stats;
    } catch (e) {
      throw Exception('Failed to get busy day stats: $e');
    }
  }

  /// Execute operations within a transaction
  Future<T> executeTransaction<T>(Future<T> Function() operation) async {
    try {
      return await _databaseHelper.transaction((txn) async {
        return await operation();
      });
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }

  /// Get database information for debugging
  Future<Map<String, dynamic>> getDataSourceInfo() async {
    try {
      final dbInfo = await _databaseHelper.getDatabaseInfo();
      final allTasks = await getAllTasks();
      
      return {
        ...dbInfo,
        'total_tasks': allTasks.length,
        'completed_tasks': allTasks.where((t) => t.isCompleted).length,
        'pending_tasks': allTasks.where((t) => !t.isCompleted).length,
      };
    } catch (e) {
      throw Exception('Failed to get data source info: $e');
    }
  }

  /// Clear all tasks (use with extreme caution)
  Future<int> clearAllTasks() async {
    try {
      return await _databaseHelper.delete(DatabaseHelper.tableTask);
    } catch (e) {
      throw Exception('Failed to clear all tasks: $e');
    }
  }
}