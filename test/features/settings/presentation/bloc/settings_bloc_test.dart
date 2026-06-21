import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:Aizen/core/error/failures.dart';
import 'package:Aizen/features/settings/domain/entities/global_settings.dart';
import 'package:Aizen/features/settings/domain/usecases/get_settings.dart';
import 'package:Aizen/features/settings/domain/usecases/save_settings.dart';
import 'package:Aizen/features/settings/domain/usecases/clear_cache.dart';
import 'package:Aizen/features/settings/domain/usecases/optimize_database.dart';
import 'package:Aizen/features/settings/domain/usecases/export_data.dart';
import 'package:Aizen/features/settings/domain/usecases/import_data.dart';
import 'package:Aizen/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:Aizen/features/settings/presentation/bloc/settings_event.dart';
import 'package:Aizen/features/settings/presentation/bloc/settings_state.dart';

class MockGetSettings extends Mock implements GetSettings {}
class MockSaveSettings extends Mock implements SaveSettings {}
class MockClearCache extends Mock implements ClearCache {}
class MockOptimizeDatabase extends Mock implements OptimizeDatabase {}
class MockExportData extends Mock implements ExportData {}
class MockImportData extends Mock implements ImportData {}

void main() {
  late MockGetSettings mockGetSettings;
  late MockSaveSettings mockSaveSettings;
  late MockClearCache mockClearCache;
  late MockOptimizeDatabase mockOptimizeDatabase;
  late MockExportData mockExportData;
  late MockImportData mockImportData;
  late SettingsBloc bloc;

  final tSettings = const GlobalSettings(
    themeMode: 'amoled',
    usageStatsGranted: true,
    systemOverlayGranted: false,
  );

  setUp(() {
    mockGetSettings = MockGetSettings();
    mockSaveSettings = MockSaveSettings();
    mockClearCache = MockClearCache();
    mockOptimizeDatabase = MockOptimizeDatabase();
    mockExportData = MockExportData();
    mockImportData = MockImportData();

    bloc = SettingsBloc(
      getSettings: mockGetSettings,
      saveSettings: mockSaveSettings,
      clearCache: mockClearCache,
      optimizeDatabase: mockOptimizeDatabase,
      exportData: mockExportData,
      importData: mockImportData,
    );

    registerFallbackValue(tSettings);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be initial status with empty settings', () {
    expect(bloc.state.status, SettingsStatus.initial);
    expect(bloc.state.settings, const GlobalSettings());
    expect(bloc.state.message, isNull);
  });

  blocTest<SettingsBloc, SettingsState>(
    'should load settings successfully from repository',
    build: () {
      when(() => mockGetSettings()).thenAnswer((_) async => (null, tSettings));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadSettingsEvent()),
    expect: () => [
      const SettingsState(status: SettingsStatus.loading),
      SettingsState(status: SettingsStatus.success, settings: tSettings),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'should emit settings save failure when saveSettings fails',
    build: () {
      when(() => mockSaveSettings(any())).thenAnswer(
        (_) async => (const PlatformFailure('Write Error'), null),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const UpdateThemeModeEvent('dark')),
    expect: () => [
      const SettingsState(
        status: SettingsStatus.failure,
        errorMessage: 'Write Error',
      ),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'should trigger database compaction successfully',
    build: () {
      when(() => mockOptimizeDatabase()).thenAnswer((_) async => (null, null));
      return bloc;
    },
    act: (bloc) => bloc.add(const TriggerOptimizeDbEvent()),
    expect: () => [
      const SettingsState(status: SettingsStatus.loading),
      const SettingsState(
        status: SettingsStatus.success,
        message: 'Database compacted and memory structures optimized',
      ),
    ],
  );
}
