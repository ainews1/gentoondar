// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: (json['start_time'] as num).toInt(),
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      isCompleted: json['is_completed'] as bool,
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'start_time': instance.startTime,
      'duration_minutes': instance.durationMinutes,
      'is_completed': instance.isCompleted,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
