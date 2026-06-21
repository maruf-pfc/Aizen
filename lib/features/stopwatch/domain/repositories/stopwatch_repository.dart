import '../../../../core/error/failures.dart';
import '../entities/lap.dart';
import '../entities/stopwatch_state.dart';

abstract class StopwatchRepository {
  Future<(Failure?, StopwatchStateEntity?)> getStopwatchState();
  Future<(Failure?, void)> saveStopwatchState(StopwatchStateEntity state);
  Future<(Failure?, List<Lap>?)> getLaps();
  Future<(Failure?, void)> saveLaps(List<Lap> laps);
  Future<(Failure?, void)> clearStopwatchData();
}
