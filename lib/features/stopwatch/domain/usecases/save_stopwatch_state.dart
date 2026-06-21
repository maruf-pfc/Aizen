import '../../../../core/error/failures.dart';
import '../entities/stopwatch_state.dart';
import '../repositories/stopwatch_repository.dart';

class SaveStopwatchState {
  final StopwatchRepository repository;

  const SaveStopwatchState(this.repository);

  Future<(Failure?, void)> call(StopwatchStateEntity state) {
    return repository.saveStopwatchState(state);
  }
}
