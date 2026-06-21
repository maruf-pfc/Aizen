import '../../../../core/error/failures.dart';
import '../entities/task.dart';
import '../repositories/todo_repository.dart';

class SaveTask {
  final TodoRepository repository;

  const SaveTask(this.repository);

  Future<(Failure?, void)> call(Task task) => repository.saveTask(task);
}
