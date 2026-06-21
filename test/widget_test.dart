import 'package:Aizen/features/stopwatch/domain/usecases/clear_stopwatch_data.dart';
import 'package:Aizen/features/stopwatch/domain/usecases/get_laps.dart';
import 'package:Aizen/features/stopwatch/domain/usecases/get_stopwatch_state.dart';
import 'package:Aizen/features/stopwatch/domain/usecases/save_laps.dart';
import 'package:Aizen/features/stopwatch/domain/usecases/save_stopwatch_state.dart';
import 'package:Aizen/features/device_info/domain/usecases/get_hardware_info.dart';
import 'package:Aizen/features/device_info/domain/usecases/get_storage_info.dart';
import 'package:Aizen/features/device_info/domain/usecases/stream_battery_info.dart';
import 'package:Aizen/features/device_info/domain/entities/hardware_info.dart';
import 'package:Aizen/features/device_info/domain/entities/storage_info.dart';
import 'package:Aizen/features/device_info/domain/entities/battery_info.dart';
import 'package:Aizen/features/todo/domain/entities/task.dart';
import 'package:Aizen/features/todo/domain/usecases/get_tasks.dart';
import 'package:Aizen/features/todo/domain/usecases/save_task.dart';
import 'package:Aizen/features/todo/domain/usecases/delete_task.dart';
import 'package:Aizen/features/todo/domain/usecases/parse_nlp_input.dart';
import 'package:Aizen/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetStopwatchState extends Mock implements GetStopwatchState {}
class MockSaveStopwatchState extends Mock implements SaveSaveStopwatchState {}
class MockGetLaps extends Mock implements GetLaps {}
class MockSaveLaps extends Mock implements SaveLaps {}
class MockClearStopwatchData extends Mock implements ClearStopwatchData {}

class MockGetHardwareInfo extends Mock implements GetHardwareInfo {}
class MockGetStorageInfo extends Mock implements GetStorageInfo {}
class MockStreamBatteryInfo extends Mock implements StreamBatteryInfo {}

class MockGetTasks extends Mock implements GetTasks {}
class MockSaveTask extends Mock implements SaveTask {}
class MockDeleteTask extends Mock implements DeleteTask {}
class MockParseNlpInput extends Mock implements ParseNlpInput {}

// Dummy implementation for SaveStopwatchState to allow mocktail stubbing
abstract class SaveSaveStopwatchState extends Mock implements SaveStopwatchState {}

void main() {
  late MockGetStopwatchState mockGetStopwatchState;
  late MockSaveStopwatchState mockSaveStopwatchState;
  late MockGetLaps mockGetLapsUsecase;
  late MockSaveLaps mockSaveLapsUsecase;
  late MockClearStopwatchData mockClearStopwatchData;

  late MockGetHardwareInfo mockGetHardwareInfo;
  late MockGetStorageInfo mockGetStorageInfo;
  late MockStreamBatteryInfo mockStreamBatteryInfo;

  late MockGetTasks mockGetTasks;
  late MockSaveTask mockSaveTask;
  late MockDeleteTask mockDeleteTask;
  late MockParseNlpInput mockParseNlpInput;

  setUp(() {
    mockGetStopwatchState = MockGetStopwatchState();
    mockSaveStopwatchState = MockSaveStopwatchState();
    mockGetLapsUsecase = MockGetLaps();
    mockSaveLapsUsecase = MockSaveLaps();
    mockClearStopwatchData = MockClearStopwatchData();

    mockGetHardwareInfo = MockGetHardwareInfo();
    mockGetStorageInfo = MockGetStorageInfo();
    mockStreamBatteryInfo = MockStreamBatteryInfo();

    mockGetTasks = MockGetTasks();
    mockSaveTask = MockSaveTask();
    mockDeleteTask = MockDeleteTask();
    mockParseNlpInput = MockParseNlpInput();

    // Default stubbing
    when(() => mockGetStopwatchState()).thenAnswer((_) async => (null, null));
    when(() => mockGetLapsUsecase()).thenAnswer((_) async => (null, null));
    when(() => mockGetTasks()).thenAnswer((_) async => (null, <Task>[]));

    when(() => mockGetHardwareInfo()).thenAnswer(
      (_) async => (
        null,
        const HardwareInfo(
          model: 'Pixel 7',
          manufacturer: 'Google',
          osVersion: 'Android 13',
          kernelArchitecture: 'arm64-v8a',
          cpuCores: 8,
          totalRamMB: 8192,
        )
      ),
    );

    when(() => mockGetStorageInfo()).thenAnswer(
      (_) async => (
        null,
        const StorageInfo(
          totalBytes: 128 * 1024 * 1024 * 1024,
          freeBytes: 96 * 1024 * 1024 * 1024,
          usedBytes: 32 * 1024 * 1024 * 1024,
        )
      ),
    );

    when(() => mockStreamBatteryInfo()).thenAnswer(
      (_) => Stream.value(
        const BatteryInfo(
          percentage: 85,
          status: ChargingStatus.discharging,
          health: 'Good',
          temperature: 29.5,
        ),
      ),
    );
  });

  testWidgets('App renders stopwatch and displays title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        getStopwatchState: mockGetStopwatchState,
        saveStopwatchState: mockSaveStopwatchState,
        getLaps: mockGetLapsUsecase,
        saveLaps: mockSaveLapsUsecase,
        clearStopwatchData: mockClearStopwatchData,
        getHardwareInfo: mockGetHardwareInfo,
        getStorageInfo: mockGetStorageInfo,
        streamBatteryInfo: mockStreamBatteryInfo,
        getTasks: mockGetTasks,
        saveTask: mockSaveTask,
        deleteTask: mockDeleteTask,
        parseNlpInput: mockParseNlpInput,
      ),
    );

    // Pump to complete the loading stream
    await tester.pump();

    // Page title should exist (Stopwatch is the default active tab on Dashboard)
    expect(find.text('AIZEN STOPWATCH'), findsOneWidget);

    // Initial stopwatch state digits should exist (00:00.00)
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('.00'), findsOneWidget);

    // Start button should exist
    expect(find.text('START'), findsOneWidget);
  });
}
