import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> saveTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _tasksKey = 'aizen_tasks_v1';

  TodoLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TaskModel>> getTasks() async {
    final list = sharedPreferences.getStringList(_tasksKey);
    if (list == null) {
      return [];
    }
    try {
      return list
          .map((e) => TaskModel.fromJson(json.decode(e) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((element) => element.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await _saveAll(tasks);
  }

  @override
  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((element) => element.id == id);
    await _saveAll(tasks);
  }

  Future<void> _saveAll(List<TaskModel> tasks) async {
    final list = tasks.map((e) => json.encode(e.toJson())).toList();
    await sharedPreferences.setStringList(_tasksKey, list);
  }
}
