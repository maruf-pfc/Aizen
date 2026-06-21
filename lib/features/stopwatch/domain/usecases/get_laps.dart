import '../../../../core/error/failures.dart';
import '../entities/lap.dart';
import '../repositories/stopwatch_repository.dart';

class GetLaps {
  final StopwatchRepository repository;

  const GetLaps(this.repository);

  Future<(Failure?, List<Lap>?)> call() {
    return repository.getLaps();
  }
}
