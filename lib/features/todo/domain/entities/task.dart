import 'package:equatable/equatable.dart';
import 'subtask.dart';
import 'tag.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final int priority; // 1 to 4 (1 = highest)
  final List<Tag> tags;
  final List<Subtask> subtasks;
  final DateTime createdAt;
  final String? recurrence; // "daily", "weekly", null

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.priority = 4,
    this.tags = const [],
    this.subtasks = const [],
    required this.createdAt,
    this.recurrence,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    int? priority,
    List<Tag>? tags,
    List<Subtask>? subtasks,
    DateTime? createdAt,
    String? recurrence,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      recurrence: recurrence ?? this.recurrence,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        isCompleted,
        dueDate,
        priority,
        tags,
        subtasks,
        createdAt,
        recurrence,
      ];
}
