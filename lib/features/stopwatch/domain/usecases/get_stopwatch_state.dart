import '../../../../core/error/failures.dart';
import '../entities/stopwatch_state.dart';
import '../repositories/stopwatch_repository.dart';

class GetStopwatchState {
  final StopwatchRepository repository;

  const GetStopwatchState(this.repository);

  Future<(Failure?, StopwatchStateEntity?)> call() {
    return repository.getStopwatchState();
  }
}
