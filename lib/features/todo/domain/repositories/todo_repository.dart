import '../../../../core/error/failures.dart';
import '../entities/task.dart';
import '../entities/nlp_parsed_result.dart';

abstract class TodoRepository {
  Future<(Failure?, List<Task>?)> getTasks();
  Future<(Failure?, void)> saveTask(Task task);
  Future<(Failure?, void)> deleteTask(String id);
  Future<(Failure?, NlpParsedResult?)> parseNlpInput(String input);
}
