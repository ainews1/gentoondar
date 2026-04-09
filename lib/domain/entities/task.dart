import 'package:equatable/equatable.dart';

/// Core task business entity with immutable properties and validation
class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.durationMinutes,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  })  : assert(title.length >= 1 && title.length <= 100, 'Title must be 1-100 characters'),
        assert(durationMinutes >= 1 && durationMinutes <= 480, 'Duration must be 1-480 minutes'),
        assert(description == null || description.length <= 500, 'Description must be max 500 characters');

  /// Unique identifier (auto-increment primary key)
  final int id;
  
  /// Task title (required, 1-100 characters)
  final String title;
  
  /// Optional description (max 500 characters)
  final String? description;
  
  /// Start time (UTC timestamp, required)
  final DateTime startTime;
  
  /// Duration in minutes (1-480 minutes = 8 hours max)
  final int durationMinutes;
  
  /// Completion status (defaults to false)
  final bool isCompleted;
  
  /// Creation timestamp (UTC)
  final DateTime createdAt;
  
  /// Last update timestamp (UTC)
  final DateTime updatedAt;

  /// End time calculated from startTime + duration
  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  /// Duration as a formatted string
  String get durationFormatted {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    }
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (minutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $minutes min';
  }

  /// Create a copy of this task with updated fields
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startTime,
    int? durationMinutes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Factory constructor to create a new task with current timestamps
  factory Task.create({
    required int id,
    required String title,
    String? description,
    required DateTime startTime,
    required int durationMinutes,
    bool isCompleted = false,
  }) {
    final now = DateTime.now().toUtc();
    return Task(
      id: id,
      title: title,
      description: description,
      startTime: startTime.toUtc(),
      durationMinutes: durationMinutes,
      isCompleted: isCompleted,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startTime,
        durationMinutes,
        isCompleted,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Task(id: $id, title: $title, startTime: $startTime, duration: $durationMinutes min, completed: $isCompleted)';
  }
}