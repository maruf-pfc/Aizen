import 'package:aizen/features/stopwatch/domain/entities/lap.dart';
import 'package:aizen/features/stopwatch/domain/entities/stopwatch_state.dart';
import 'package:aizen/features/stopwatch/domain/repositories/stopwatch_repository.dart';
import 'package:aizen/features/stopwatch/domain/usecases/clear_stopwatch_data.dart';
import 'package:aizen/features/stopwatch/domain/usecases/get_laps.dart';
import 'package:aizen/features/stopwatch/domain/usecases/get_stopwatch_state.dart';
import 'package:aizen/features/stopwatch/domain/usecases/save_laps.dart';
import 'package:aizen/features/stopwatch/domain/usecases/save_stopwatch_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStopwatchRepository extends Mock implements StopwatchRepository {}

void main() {
  late MockStopwatchRepository mockRepository;
  late GetStopwatchState getStopwatchState;
  late SaveStopwatchState saveStopwatchState;
  late GetLaps getLaps;
  late SaveLaps saveLaps;
  late ClearStopwatchData clearStopwatchData;

  setUp(() {
    mockRepository = MockStopwatchRepository();
    getStopwatchState = GetStopwatchState(mockRepository);
    saveStopwatchState = SaveStopwatchState(mockRepository);
    getLaps = GetLaps(mockRepository);
    saveLaps = SaveLaps(mockRepository);
    clearStopwatchData = ClearStopwatchData(mockRepository);
  });

  group('Usecases Tests', () {
    final tState = StopwatchStateEntity(
      elapsedTime: const Duration(seconds: 10),
      isRunning: false,
      startTime: null,
    );
    final tLaps = [
      const Lap(
        index: 1,
        lapTime: Duration(seconds: 5),
        cumulativeTime: Duration(seconds: 5),
      ),
    ];

    test('should get stopwatch state from repository', () async {
      when(() => mockRepository.getStopwatchState())
          .thenAnswer((_) async => (null, tState));

      final result = await getStopwatchState();

      expect(result, (null, tState));
      verify(() => mockRepository.getStopwatchState()).called(1);
    });

    test('should save stopwatch state in repository', () async {
      when(() => mockRepository.saveStopwatchState(tState))
          .thenAnswer((_) async => (null, null));

      final result = await saveStopwatchState(tState);

      expect(result, (null, null));
      verify(() => mockRepository.saveStopwatchState(tState)).called(1);
    });

    test('should get laps from repository', () async {
      when(() => mockRepository.getLaps())
          .thenAnswer((_) async => (null, tLaps));

      final result = await getLaps();

      expect(result, (null, tLaps));
      verify(() => mockRepository.getLaps()).called(1);
    });

    test('should save laps in repository', () async {
      when(() => mockRepository.saveLaps(tLaps))
          .thenAnswer((_) async => (null, null));

      final result = await saveLaps(tLaps);

      expect(result, (null, null));
      verify(() => mockRepository.saveLaps(tLaps)).called(1);
    });

    test('should clear stopwatch data in repository', () async {
      when(() => mockRepository.clearStopwatchData())
          .thenAnswer((_) async => (null, null));

      final result = await clearStopwatchData();

      expect(result, (null, null));
      verify(() => mockRepository.clearStopwatchData()).called(1);
    });
  });
}
