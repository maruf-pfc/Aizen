import '../../../../core/error/failures.dart';
import '../entities/nlp_parsed_result.dart';
import '../repositories/todo_repository.dart';

class ParseNlpInput {
  final TodoRepository repository;

  const ParseNlpInput(this.repository);

  Future<(Failure?, NlpParsedResult?)> call(String input) =>
      repository.parseNlpInput(input);
}
