import 'package:aizen/features/stopwatch/domain/usecases/clear_stopwatch_data.dart';
import 'package:aizen/features/stopwatch/domain/usecases/get_laps.dart';
import 'package:aizen/features/stopwatch/domain/usecases/get_stopwatch_state.dart';
import 'package:aizen/features/stopwatch/domain/usecases/save_laps.dart';
import 'package:aizen/features/stopwatch/domain/usecases/save_stopwatch_state.dart';
import 'package:aizen/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetStopwatchState extends Mock implements GetStopwatchState {}
class MockSaveStopwatchState extends Mock implements SaveSaveStopwatchState {}
class MockGetLaps extends Mock implements GetLaps {}
class MockSaveLaps extends Mock implements SaveLaps {}
class MockClearStopwatchData extends Mock implements ClearStopwatchData {}

// Dummy implementation for SaveStopwatchState to allow mocktail stubbing
abstract class SaveSaveStopwatchState extends Mock implements SaveStopwatchState {}

void main() {
  late MockGetStopwatchState mockGetStopwatchState;
  late MockSaveStopwatchState mockSaveStopwatchState;
  late MockGetLaps mockGetLapsUsecase;
  late MockSaveLaps mockSaveLapsUsecase;
  late MockClearStopwatchData mockClearStopwatchData;

  setUp(() {
    mockGetStopwatchState = MockGetStopwatchState();
    mockSaveStopwatchState = MockSaveStopwatchState();
    mockGetLapsUsecase = MockGetLaps();
    mockSaveLapsUsecase = MockSaveLaps();
    mockClearStopwatchData = MockClearStopwatchData();

    // Default stubbing
    when(() => mockGetStopwatchState()).thenAnswer((_) async => (null, null));
    when(() => mockGetLapsUsecase()).thenAnswer((_) async => (null, null));
  });

  testWidgets('App renders stopwatch and displays title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        getStopwatchState: mockGetStopwatchState,
        saveStopwatchState: mockSaveStopwatchState,
        getLaps: mockGetLapsUsecase,
        saveLaps: mockSaveLapsUsecase,
        clearStopwatchData: mockClearStopwatchData,
      ),
    );

    // Pump to complete the loading stream
    await tester.pump();

    // Page title should exist
    expect(find.text('AIZEN STOPWATCH'), findsOneWidget);

    // Initial stopwatch state digits should exist (00:00.00)
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('.00'), findsOneWidget);

    // Start button should exist
    expect(find.text('START'), findsOneWidget);
  });
}
