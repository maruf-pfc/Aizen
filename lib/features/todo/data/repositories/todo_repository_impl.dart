import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/nlp_parsed_result.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/failures/todo_failures.dart';
import '../datasources/todo_local_data_source.dart';
import '../models/task_model.dart';
import '../services/nlp_parser_service.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  final NlpParserService nlpParserService;

  TodoRepositoryImpl({
    required this.localDataSource,
    required this.nlpParserService,
  });

  @override
  Future<(Failure?, List<Task>?)> getTasks() async {
    try {
      final tasks = await localDataSource.getTasks();
      return (null, tasks);
    } catch (e) {
      return (TodoDatabaseFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, void)> saveTask(Task task) async {
    try {
      final model = TaskModel.fromEntity(task);
      await localDataSource.saveTask(model);
      return (null, null);
    } catch (e) {
      return (TodoDatabaseFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, void)> deleteTask(String id) async {
    try {
      await localDataSource.deleteTask(id);
      return (null, null);
    } catch (e) {
      return (TodoDatabaseFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, NlpParsedResult?)> parseNlpInput(String input) async {
    try {
      final result = nlpParserService.parse(input);
      return (null, result);
    } catch (e) {
      return (TodoNlpParsingFailure(e.toString()), null);
    }
  }
}
