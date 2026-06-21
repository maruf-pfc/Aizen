import '../../../../core/error/failures.dart';
import '../repositories/todo_repository.dart';

class DeleteTask {
  final TodoRepository repository;

  const DeleteTask(this.repository);

  Future<(Failure?, void)> call(String id) => repository.deleteTask(id);
}
