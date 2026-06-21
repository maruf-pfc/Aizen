import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/save_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/parse_nlp_input.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTasks getTasks;
  final SaveTask saveTask;
  final DeleteTask deleteTask;
  final ParseNlpInput parseNlpInput;

  TodoBloc({
    required this.getTasks,
    required this.saveTask,
    required this.deleteTask,
    required this.parseNlpInput,
  }) : super(const TodoState()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<ToggleSubtaskEvent>(_onToggleSubtask);
    on<ChangeSortOrderEvent>(_onChangeSortOrder);
    on<RescheduleTodoEvent>(_onRescheduleTodo);
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    emit(state.copyWith(status: TodoStatus.loading));
    final result = await getTasks();

    final failure = result.$1;
    final tasksList = result.$2;

    if (failure != null) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: failure.message,
      ));
      return;
    }

    final sortedTasks = _sortTasks(tasksList ?? [], state.sortOrder);
    emit(state.copyWith(
      status: TodoStatus.success,
      tasks: sortedTasks,
    ));
  }

  Future<void> _onAddTodo(
    AddTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    if (event.nlpInput.trim().isEmpty) return;

    final parseResult = await parseNlpInput(event.nlpInput);
    final nlpData = parseResult.$2;

    if (nlpData == null) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: parseResult.$1?.message ?? 'Failed to parse NLP input',
      ));
      return;
    }

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: nlpData.title,
      isCompleted: false,
      dueDate: nlpData.dueDate,
      priority: nlpData.priority,
      tags: nlpData.tags,
      subtasks: const [],
      createdAt: DateTime.now(),
    );

    final saveResult = await saveTask(newTask);
    if (saveResult.$1 != null) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: saveResult.$1!.message,
      ));
      return;
    }

    add(const LoadTodosEvent());
  }

  Future<void> _onToggleTodo(
    ToggleTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    final taskIndex = state.tasks.indexWhere((t) => t.id == event.taskId);
    if (taskIndex < 0) return;

    final task = state.tasks[taskIndex];
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

    final saveResult = await saveTask(updatedTask);
    if (saveResult.$1 != null) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: saveResult.$1!.message,
      ));
      return;
    }

    add(const LoadTodosEvent());
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    final deleteResult = await deleteTask(event.taskId);
    if (deleteResult.$1 != null) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: deleteResult.$1!.message,
      ));
      return;
    }

    add(const LoadTodosEvent());
  }

  Future<void> _onToggleSubtask(
    ToggleSubtaskEvent event,
    Emitter<TodoState> emit,
  ) async {
    final taskIndex = state.tasks.indexWhere((t) => t.id == event.taskId);
    if (taskIndex < 0) return;

    final task = state.tasks[taskIndex];
    final updatedSubtasks = task.subtasks.map((sub) {
      if (sub.id == event.subtaskId) {
        return sub.copyWith(isCompleted: !sub.isCompleted);
      }
      return sub;
    }).toList();

    final updatedTask = task.copyWith(subtasks: updatedSubtasks);

    final saveResult = await saveTask(updatedTask);
    if (saveResult.$1 != null) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: saveResult.$1!.message,
      ));
      return;
    }

    add(const LoadTodosEvent());
  }

  void _onChangeSortOrder(
    ChangeSortOrderEvent event,
    Emitter<TodoState> emit,
  ) {
    final sortedTasks = _sortTasks(state.tasks, event.sortOrder);
    emit(state.copyWith(
      sortOrder: event.sortOrder,
      tasks: sortedTasks,
    ));
  }

  Future<void> _onRescheduleTodo(
    RescheduleTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    final taskIndex = state.tasks.indexWhere((t) => t.id == event.taskId);
    if (taskIndex < 0) return;

    final task = state.tasks[taskIndex];
    final updatedTask = task.copyWith(dueDate: event.dueDate);

    final saveResult = await saveTask(updatedTask);
    if (saveResult.$1 != null) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: saveResult.$1!.message,
      ));
      return;
    }

    add(const LoadTodosEvent());
  }

  List<Task> _sortTasks(List<Task> tasks, SortOrder sortOrder) {
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      // 1. Completed tasks always go to the bottom
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;

      // 2. Secondary sort based on selection
      switch (sortOrder) {
        case SortOrder.priority:
          final priorityCompare = a.priority.compareTo(b.priority);
          if (priorityCompare != 0) return priorityCompare;
          if (a.dueDate == null && b.dueDate != null) return 1;
          if (a.dueDate != null && b.dueDate == null) return -1;
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          }
          return a.createdAt.compareTo(b.createdAt);

        case SortOrder.dueDate:
          if (a.dueDate == null && b.dueDate != null) return 1;
          if (a.dueDate != null && b.dueDate == null) return -1;
          if (a.dueDate != null && b.dueDate != null) {
            final dateCompare = a.dueDate!.compareTo(b.dueDate!);
            if (dateCompare != 0) return dateCompare;
          }
          return a.priority.compareTo(b.priority);

        case SortOrder.creationDate:
          return b.createdAt.compareTo(a.createdAt); // newest first
      }
    });
    return sorted;
  }
}
