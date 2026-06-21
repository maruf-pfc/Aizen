import '../../../../core/error/failures.dart';
import '../repositories/stopwatch_repository.dart';

class ClearStopwatchData {
  final StopwatchRepository repository;

  const ClearStopwatchData(this.repository);

  Future<(Failure?, void)> call() {
    return repository.clearStopwatchData();
  }
}
