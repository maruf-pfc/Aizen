import '../../../../core/error/failures.dart';
import '../../domain/entities/lap.dart';
import '../../domain/entities/stopwatch_state.dart';
import '../../domain/repositories/stopwatch_repository.dart';
import '../datasources/stopwatch_local_data_source.dart';
import '../models/lap_model.dart';
import '../models/stopwatch_state_model.dart';

class StopwatchRepositoryImpl implements StopwatchRepository {
  final StopwatchLocalDataSource localDataSource;

  const StopwatchRepositoryImpl({required this.localDataSource});

  @override
  Future<(Failure?, StopwatchStateEntity?)> getStopwatchState() async {
    try {
      final state = await localDataSource.getStopwatchState();
      return (null, state);
    } catch (e) {
      return (CacheFailure('Failed to load stopwatch state: $e'), null);
    }
  }

  @override
  Future<(Failure?, void)> saveStopwatchState(StopwatchStateEntity state) async {
    try {
      final model = StopwatchStateModel.fromEntity(state);
      await localDataSource.saveStopwatchState(model);
      return (null, null);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return (CacheFailure('Failed to save stopwatch state: $e'), null);
    }
  }

  @override
  Future<(Failure?, List<Lap>?)> getLaps() async {
    try {
      final laps = await localDataSource.getLaps();
      return (null, laps);
    } catch (e) {
      return (CacheFailure('Failed to load laps: $e'), null);
    }
  }

  @override
  Future<(Failure?, void)> saveLaps(List<Lap> laps) async {
    try {
      final models = laps.map((lap) => LapModel.fromEntity(lap)).toList();
      await localDataSource.saveLaps(models);
      return (null, null);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return (CacheFailure('Failed to save laps: $e'), null);
    }
  }

  @override
  Future<(Failure?, void)> clearStopwatchData() async {
    try {
      await localDataSource.clearData();
      return (null, null);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return (CacheFailure('Failed to clear stopwatch data: $e'), null);
    }
  }
}
