import '../../domain/entities/subtask.dart';

class SubtaskModel extends Subtask {
  const SubtaskModel({
    required super.id,
    required super.title,
    super.isCompleted = false,
  });

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubtaskModel.fromEntity(Subtask subtask) {
    return SubtaskModel(
      id: subtask.id,
      title: subtask.title,
      isCompleted: subtask.isCompleted,
    );
  }
}
