import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database helper with singleton pattern and optimized task schema
class DatabaseHelper {
  static const String _databaseName = 'task_calendar.db';
  static const int _databaseVersion = 1;
  
  static const String tableTask = 'tasks';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database with optimized schema and indexes
  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _databaseName);
      
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onOpen: _onOpen,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw DatabaseException('Failed to initialize database: $e');
    }
  }

  /// Create database schema on first run
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTask (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL CHECK(length(title) BETWEEN 1 AND 100),
        description TEXT CHECK(description IS NULL OR length(description) <= 500),
        start_time INTEGER NOT NULL,
        duration_minutes INTEGER NOT NULL CHECK(duration_minutes BETWEEN 1 AND 480),
        is_completed INTEGER DEFAULT 0 CHECK(is_completed IN (0, 1)),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create optimized indexes for calendar app query patterns
    await _createIndexes(db);
    
    print('Database created successfully with version $version');
  }

  /// Create indexes for efficient calendar queries
  Future<void> _createIndexes(Database db) async {
    // Index for date-based queries (most common in calendar apps)
    await db.execute('''
      CREATE INDEX idx_tasks_date 
      ON $tableTask(date(start_time/1000, 'unixepoch', 'localtime'))
    ''');

    // Index for time-based sorting and range queries
    await db.execute('''
      CREATE INDEX idx_tasks_start_time 
      ON $tableTask(start_time)
    ''');

    // Index for completion status filtering
    await db.execute('''
      CREATE INDEX idx_tasks_completed 
      ON $tableTask(is_completed)
    ''');

    // Composite index for date + completion status (common filter combination)
    await db.execute('''
      CREATE INDEX idx_tasks_date_completed 
      ON $tableTask(date(start_time/1000, 'unixepoch', 'localtime'), is_completed)
    ''');

    print('Database indexes created successfully');
  }

  /// Handle database upgrades (future schema changes)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    
    // Future schema migrations will go here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE $tableTask ADD COLUMN priority INTEGER DEFAULT 0');
    // }
  }

  /// Called when database is opened
  Future<void> _onOpen(Database db) async {
    // Enable foreign key support
    await db.execute('PRAGMA foreign_keys = ON');
    
    // Enable WAL mode for better concurrent access
    await db.execute('PRAGMA journal_mode = WAL');
    
    // Optimize SQLite settings for mobile
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA cache_size = 10000');
    await db.execute('PRAGMA temp_store = MEMORY');
    
    print('Database opened and optimized');
  }

  /// Execute a query with error handling
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      return await db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw DatabaseException('Query failed: $e');
    }
  }

  /// Insert record with error handling
  Future<int> insert(String table, Map<String, dynamic> values) async {
    try {
      final db = await database;
      return await db.insert(table, values, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw DatabaseException('Insert failed: $e');
    }
  }

  /// Update record with error handling
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.update(table, values, where: where, whereArgs: whereArgs);
    } catch (e) {
      throw DatabaseException('Update failed: $e');
    }
  }

  /// Delete record with error handling
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    try {
      final db = await database;
      return await db.delete(table, where: where, whereArgs: whereArgs);
    } catch (e) {
      throw DatabaseException('Delete failed: $e');
    }
  }

  /// Execute raw SQL with error handling
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      throw DatabaseException('Raw query failed: $e');
    }
  }

  /// Execute transaction with error handling
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    try {
      final db = await database;
      return await db.transaction(action);
    } catch (e) {
      throw DatabaseException('Transaction failed: $e');
    }
  }

  /// Get database info for debugging
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final path = db.path;
    final version = await db.getVersion();
    
    // Get table count and row counts
    final tables = await rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    final taskCount = await rawQuery("SELECT COUNT(*) as count FROM $tableTask");
    
    return {
      'path': path,
      'version': version,
      'tables': tables.map((t) => t['name']).toList(),
      'task_count': taskCount.first['count'],
      'indexes': await _getIndexInfo(),
    };
  }

  /// Get index information for debugging
  Future<List<Map<String, dynamic>>> _getIndexInfo() async {
    return await rawQuery("SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='$tableTask'");
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      print('Database closed');
    }
  }

  /// Delete database file (use with caution)
  Future<void> deleteDatabase() async {
    await close();
    String path = join(await getDatabasesPath(), _databaseName);
    await databaseFactory.deleteDatabase(path);
    print('Database deleted');
  }
}

/// Custom exception for database operations
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  
  @override
  String toString() => 'DatabaseException: $message';
}