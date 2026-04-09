import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

/// Data model for Task entity with JSON serialization capabilities
@JsonSerializable(explicitToJson: true)
class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.durationMinutes,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier (auto-increment primary key)
  final int id;

  /// Task title (required, 1-100 characters)
  final String title;

  /// Optional description (max 500 characters)
  final String? description;

  /// Start time as milliseconds since Unix epoch (UTC)
  @JsonKey(name: 'start_time')
  final int startTime;

  /// Duration in minutes (1-480 minutes = 8 hours max)
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;

  /// Completion status
  @JsonKey(name: 'is_completed')
  final bool isCompleted;

  /// Creation timestamp as milliseconds since Unix epoch (UTC)
  @JsonKey(name: 'created_at')
  final int createdAt;

  /// Last update timestamp as milliseconds since Unix epoch (UTC)
  @JsonKey(name: 'updated_at')
  final int updatedAt;

  /// Convert TaskModel to domain Task entity
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime, isUtc: true),
      durationMinutes: durationMinutes,
      isCompleted: isCompleted,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt, isUtc: true),
    );
  }

  /// Create TaskModel from domain Task entity
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      startTime: task.startTime.toUtc().millisecondsSinceEpoch,
      durationMinutes: task.durationMinutes,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt.toUtc().millisecondsSinceEpoch,
      updatedAt: task.updatedAt.toUtc().millisecondsSinceEpoch,
    );
  }

  /// Create TaskModel from JSON map (for database/API deserialization)
  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);

  /// Convert TaskModel to JSON map (for database/API serialization)
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  /// Create a copy of this model with updated fields
  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    int? startTime,
    int? durationMinutes,
    bool? isCompleted,
    int? createdAt,
    int? updatedAt,
  }) {
    return TaskModel(
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

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, startTime: ${DateTime.fromMillisecondsSinceEpoch(startTime, isUtc: true)}, '
        'duration: $durationMinutes min, completed: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.startTime == startTime &&
        other.durationMinutes == durationMinutes &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      startTime,
      durationMinutes,
      isCompleted,
      createdAt,
      updatedAt,
    );
  }
}