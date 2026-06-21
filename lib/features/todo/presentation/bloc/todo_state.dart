import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';
import 'todo_event.dart';

enum TodoStatus { initial, loading, success, failure }

class TodoState extends Equatable {
  final TodoStatus status;
  final List<Task> tasks;
  final SortOrder sortOrder;
  final String? errorMessage;

  const TodoState({
    this.status = TodoStatus.initial,
    this.tasks = const [],
    this.sortOrder = SortOrder.priority,
    this.errorMessage,
  });

  TodoState copyWith({
    TodoStatus? status,
    List<Task>? tasks,
    SortOrder? sortOrder,
    String? errorMessage,
  }) {
    return TodoState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      sortOrder: sortOrder ?? this.sortOrder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, sortOrder, errorMessage];
}
