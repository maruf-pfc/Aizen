import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:Aizen/core/error/failures.dart';
import 'package:Aizen/features/device_info/domain/entities/battery_info.dart';
import 'package:Aizen/features/device_info/domain/entities/hardware_info.dart';
import 'package:Aizen/features/device_info/domain/entities/storage_info.dart';
import 'package:Aizen/features/device_info/domain/usecases/get_hardware_info.dart';
import 'package:Aizen/features/device_info/domain/usecases/get_storage_info.dart';
import 'package:Aizen/features/device_info/domain/usecases/stream_battery_info.dart';
import 'package:Aizen/features/device_info/presentation/bloc/device_info_bloc.dart';
import 'package:Aizen/features/device_info/presentation/bloc/device_info_event.dart';
import 'package:Aizen/features/device_info/presentation/bloc/device_info_state.dart';

class MockGetHardwareInfo extends Mock implements GetHardwareInfo {}
class MockGetStorageInfo extends Mock implements GetStorageInfo {}
class MockStreamBatteryInfo extends Mock implements StreamBatteryInfo {}

void main() {
  late MockGetHardwareInfo mockGetHardwareInfo;
  late MockGetStorageInfo mockGetStorageInfo;
  late MockStreamBatteryInfo mockStreamBatteryInfo;
  late DeviceInfoBloc bloc;

  const tHardwareInfo = HardwareInfo(
    model: 'Pixel 7',
    manufacturer: 'Google',
    osVersion: 'Android 13',
    kernelArchitecture: 'arm64-v8a',
    cpuCores: 8,
    totalRamMB: 8192,
  );

  const tStorageInfo = StorageInfo(
    totalBytes: 100 * 1024 * 1024 * 1024,
    freeBytes: 60 * 1024 * 1024 * 1024,
    usedBytes: 40 * 1024 * 1024 * 1024,
  );

  const tBatteryInfo = BatteryInfo(
    percentage: 85,
    status: ChargingStatus.discharging,
    health: 'Good',
    temperature: 29.5,
  );

  setUp(() {
    mockGetHardwareInfo = MockGetHardwareInfo();
    mockGetStorageInfo = MockGetStorageInfo();
    mockStreamBatteryInfo = MockStreamBatteryInfo();

    bloc = DeviceInfoBloc(
      getHardwareInfo: mockGetHardwareInfo,
      getStorageInfo: mockGetStorageInfo,
      streamBatteryInfo: mockStreamBatteryInfo,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be empty and initial status', () {
    expect(bloc.state.status, DeviceInfoStatus.initial);
    expect(bloc.state.hardwareInfo, isNull);
    expect(bloc.state.batteryInfo, isNull);
    expect(bloc.state.storageInfo, isNull);
  });

  blocTest<DeviceInfoBloc, DeviceInfoState>(
    'should emit [loading, success] when fetching data is successful',
    build: () {
      when(() => mockGetHardwareInfo()).thenAnswer((_) async => (null, tHardwareInfo));
      when(() => mockGetStorageInfo()).thenAnswer((_) async => (null, tStorageInfo));
      when(() => mockStreamBatteryInfo()).thenAnswer((_) => Stream.value(tBatteryInfo));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadDeviceInfoEvent()),
    expect: () => [
      const DeviceInfoState(status: DeviceInfoStatus.loading),
      const DeviceInfoState(
        status: DeviceInfoStatus.success,
        hardwareInfo: tHardwareInfo,
        storageInfo: tStorageInfo,
      ),
      const DeviceInfoState(
        status: DeviceInfoStatus.success,
        hardwareInfo: tHardwareInfo,
        storageInfo: tStorageInfo,
        batteryInfo: tBatteryInfo,
      ),
    ],
  );

  blocTest<DeviceInfoBloc, DeviceInfoState>(
    'should emit [loading, failure] when fetching hardware specs fails',
    build: () {
      when(() => mockGetHardwareInfo()).thenAnswer(
        (_) async => (const PlatformFailure('Hardware Failure'), null),
      );
      when(() => mockGetStorageInfo()).thenAnswer((_) async => (null, tStorageInfo));
      when(() => mockStreamBatteryInfo()).thenAnswer((_) => Stream.empty());
      return bloc;
    },
    act: (bloc) => bloc.add(LoadDeviceInfoEvent()),
    expect: () => [
      const DeviceInfoState(status: DeviceInfoStatus.loading),
      const DeviceInfoState(
        status: DeviceInfoStatus.failure,
        errorMessage: 'Hardware Failure',
      ),
    ],
  );

  blocTest<DeviceInfoBloc, DeviceInfoState>(
    'should cancel stream when PauseBatteryTrackingEvent is added',
    build: () {
      when(() => mockGetHardwareInfo()).thenAnswer((_) async => (null, tHardwareInfo));
      when(() => mockGetStorageInfo()).thenAnswer((_) async => (null, tStorageInfo));
      when(() => mockStreamBatteryInfo()).thenAnswer((_) => Stream.value(tBatteryInfo));
      return bloc;
    },
    act: (bloc) async {
      bloc.add(LoadDeviceInfoEvent());
      await Future.delayed(const Duration(milliseconds: 10));
      bloc.add(PauseBatteryTrackingEvent());
    },
    expect: () => [
      const DeviceInfoState(status: DeviceInfoStatus.loading),
      const DeviceInfoState(
        status: DeviceInfoStatus.success,
        hardwareInfo: tHardwareInfo,
        storageInfo: tStorageInfo,
      ),
      const DeviceInfoState(
        status: DeviceInfoStatus.success,
        hardwareInfo: tHardwareInfo,
        storageInfo: tStorageInfo,
        batteryInfo: tBatteryInfo,
      ),
    ],
  );
}
