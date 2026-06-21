import '../../../../core/error/failures.dart';
import '../entities/lap.dart';
import '../repositories/stopwatch_repository.dart';

class SaveLaps {
  final StopwatchRepository repository;

  const SaveLaps(this.repository);

  Future<(Failure?, void)> call(List<Lap> laps) {
    return repository.saveLaps(laps);
  }
}
