import 'package:aizen/features/stopwatch/domain/entities/lap.dart';
import 'package:aizen/features/stopwatch/domain/entities/stopwatch_state.dart';
import 'package:aizen/features/stopwatch/domain/usecases/clear_stopwatch_data.dart';
import 'package:aizen/features/stopwatch/domain/usecases/get_laps.dart';
import 'package:aizen/features/stopwatch/domain/usecases/get_stopwatch_state.dart';
import 'package:aizen/features/stopwatch/domain/usecases/save_laps.dart';
import 'package:aizen/features/stopwatch/domain/usecases/save_stopwatch_state.dart';
import 'package:aizen/features/stopwatch/presentation/bloc/stopwatch_bloc.dart';
import 'package:aizen/features/stopwatch/presentation/bloc/stopwatch_event.dart';
import 'package:aizen/features/stopwatch/presentation/bloc/stopwatch_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetStopwatchState extends Mock implements GetStopwatchState {}
class MockSaveStopwatchState extends Mock implements SaveStopwatchState {}
class MockGetLaps extends Mock implements GetLaps {}
class MockSaveLaps extends Mock implements SaveLaps {}
class MockClearStopwatchData extends Mock implements ClearStopwatchData {}

void main() {
  late MockGetStopwatchState mockGetStopwatchState;
  late MockSaveStopwatchState mockSaveStopwatchState;
  late MockGetLaps mockGetLapsUsecase;
  late MockSaveLaps mockSaveLapsUsecase;
  late MockClearStopwatchData mockClearStopwatchData;
  late StopwatchBloc stopwatchBloc;

  setUpAll(() {
    registerFallbackValue(
      const StopwatchStateEntity(
        elapsedTime: Duration.zero,
        isRunning: false,
        startTime: null,
      ),
    );
    registerFallbackValue(const <Lap>[]);
  });

  setUp(() {
    mockGetStopwatchState = MockGetStopwatchState();
    mockSaveStopwatchState = MockSaveStopwatchState();
    mockGetLapsUsecase = MockGetLaps();
    mockSaveLapsUsecase = MockSaveLaps();
    mockClearStopwatchData = MockClearStopwatchData();

    stopwatchBloc = StopwatchBloc(
      getStopwatchState: mockGetStopwatchState,
      saveStopwatchState: mockSaveStopwatchState,
      getLaps: mockGetLapsUsecase,
      saveLaps: mockSaveLapsUsecase,
      clearStopwatchData: mockClearStopwatchData,
    );
  });

  tearDown(() {
    stopwatchBloc.close();
  });

  test('initial state should be empty and initial status', () {
    expect(stopwatchBloc.state, const StopwatchState());
  });

  group('LoadStopwatchDataEvent', () {
    blocTest<StopwatchBloc, StopwatchState>(
      'should emit [loading, initial] when no data is saved',
      build: () {
        when(() => mockGetStopwatchState()).thenAnswer((_) async => (null, null));
        when(() => mockGetLapsUsecase()).thenAnswer((_) async => (null, null));
        return stopwatchBloc;
      },
      act: (bloc) => bloc.add(const LoadStopwatchDataEvent()),
      expect: () => [
        const StopwatchState(status: StopwatchStatus.loading),
        const StopwatchState(
          status: StopwatchStatus.initial,
          elapsedTime: Duration.zero,
          laps: [],
        ),
      ],
    );

    blocTest<StopwatchBloc, StopwatchState>(
      'should emit [loading, paused] when saved state is paused',
      build: () {
        final savedState = StopwatchStateEntity(
          elapsedTime: const Duration(seconds: 15),
          isRunning: false,
          startTime: null,
        );
        final savedLaps = [
          const Lap(
            index: 1,
            lapTime: Duration(seconds: 15),
            cumulativeTime: Duration(seconds: 15),
          )
        ];
        when(() => mockGetStopwatchState()).thenAnswer((_) async => (null, savedState));
        when(() => mockGetLapsUsecase()).thenAnswer((_) async => (null, savedLaps));
        return stopwatchBloc;
      },
      act: (bloc) => bloc.add(const LoadStopwatchDataEvent()),
      expect: () => [
        const StopwatchState(status: StopwatchStatus.loading),
        StopwatchState(
          status: StopwatchStatus.paused,
          elapsedTime: const Duration(seconds: 15),
          laps: const [
            Lap(
              index: 1,
              lapTime: Duration(seconds: 15),
              cumulativeTime: Duration(seconds: 15),
            )
          ],
        ),
      ],
    );
  });

  group('Start/Pause/Reset Events', () {
    blocTest<StopwatchBloc, StopwatchState>(
      'should emit [running] when StartStopwatchEvent is added',
      build: () {
        when(() => mockSaveStopwatchState(any())).thenAnswer((_) async => (null, null));
        return stopwatchBloc;
      },
      act: (bloc) => bloc.add(const StartStopwatchEvent()),
      verify: (bloc) {
        expect(bloc.state.status, StopwatchStatus.running);
        expect(bloc.state.startTime, isNotNull);
        verify(() => mockSaveStopwatchState(any())).called(1);
      },
    );

    blocTest<StopwatchBloc, StopwatchState>(
      'should emit [paused] when PauseStopwatchEvent is added',
      build: () {
        when(() => mockSaveStopwatchState(any())).thenAnswer((_) async => (null, null));
        return stopwatchBloc;
      },
      seed: () => StopwatchState(
        status: StopwatchStatus.running,
        startTime: DateTime.now().subtract(const Duration(seconds: 10)),
        elapsedTime: const Duration(seconds: 5),
      ),
      act: (bloc) => bloc.add(const PauseStopwatchEvent()),
      verify: (bloc) {
        expect(bloc.state.status, StopwatchStatus.paused);
        expect(bloc.state.startTime, isNull);
        // elapsedTime should be base (5) + session (~10) = ~15s
        expect(bloc.state.elapsedTime.inSeconds >= 14, true);
        verify(() => mockSaveStopwatchState(any())).called(1);
      },
    );

    blocTest<StopwatchBloc, StopwatchState>(
      'should emit [initial] and clear storage when ResetStopwatchEvent is added',
      build: () {
        when(() => mockClearStopwatchData()).thenAnswer((_) async => (null, null));
        return stopwatchBloc;
      },
      seed: () => const StopwatchState(
        status: StopwatchStatus.paused,
        elapsedTime: Duration(seconds: 10),
        laps: [
          Lap(
            index: 1,
            lapTime: Duration(seconds: 10),
            cumulativeTime: Duration(seconds: 10),
          )
        ],
      ),
      act: (bloc) => bloc.add(const ResetStopwatchEvent()),
      expect: () => [
        const StopwatchState(status: StopwatchStatus.initial),
      ],
      verify: (bloc) {
        verify(() => mockClearStopwatchData()).called(1);
      },
    );
  });
}
