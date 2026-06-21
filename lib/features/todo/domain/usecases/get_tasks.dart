import '../../../../core/error/failures.dart';
import '../entities/task.dart';
import '../repositories/todo_repository.dart';

class GetTasks {
  final TodoRepository repository;

  const GetTasks(this.repository);

  Future<(Failure?, List<Task>?)> call() => repository.getTasks();
}
