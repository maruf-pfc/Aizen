import '../../domain/entities/task.dart';
import 'subtask_model.dart';
import 'tag_model.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    super.isCompleted = false,
    super.dueDate,
    super.priority = 4,
    super.tags = const [],
    super.subtasks = const [],
    required super.createdAt,
    super.recurrence,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      priority: json['priority'] as int? ?? 4,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((e) => SubtaskModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      recurrence: json['recurrence'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'tags': tags.map((e) => TagModel.fromEntity(e).toJson()).toList(),
      'subtasks': subtasks.map((e) => SubtaskModel.fromEntity(e).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'recurrence': recurrence,
    };
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      isCompleted: task.isCompleted,
      dueDate: task.dueDate,
      priority: task.priority,
      tags: task.tags,
      subtasks: task.subtasks,
      createdAt: task.createdAt,
      recurrence: task.recurrence,
    );
  }
}
