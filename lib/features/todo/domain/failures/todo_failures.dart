import '../../../../core/error/failures.dart';

class TodoDatabaseFailure extends Failure {
  const TodoDatabaseFailure(super.message);
}

class TodoNlpParsingFailure extends Failure {
  const TodoNlpParsingFailure(super.message);
}
