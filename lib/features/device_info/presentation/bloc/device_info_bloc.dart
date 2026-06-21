import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_hardware_info.dart';
import '../../domain/usecases/get_storage_info.dart';
import '../../domain/usecases/stream_battery_info.dart';
import 'device_info_event.dart';
import 'device_info_state.dart';

class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  final GetHardwareInfo getHardwareInfo;
  final GetStorageInfo getStorageInfo;
  final StreamBatteryInfo streamBatteryInfo;

  StreamSubscription? _batterySubscription;

  DeviceInfoBloc({
    required this.getHardwareInfo,
    required this.getStorageInfo,
    required this.streamBatteryInfo,
  }) : super(const DeviceInfoState()) {
    on<LoadDeviceInfoEvent>(_onLoadDeviceInfo);
    on<PauseBatteryTrackingEvent>(_onPauseBatteryTracking);
    on<BatteryUpdatedEvent>(_onBatteryUpdated);
  }

  Future<void> _onLoadDeviceInfo(
    LoadDeviceInfoEvent event,
    Emitter<DeviceInfoState> emit,
  ) async {
    emit(state.copyWith(status: DeviceInfoStatus.loading));

    final hardwareResult = await getHardwareInfo();
    final storageResult = await getStorageInfo();

    final hwFailure = hardwareResult.$1;
    final hwData = hardwareResult.$2;

    final stFailure = storageResult.$1;
    final stData = storageResult.$2;

    if (hwFailure != null || stFailure != null) {
      emit(state.copyWith(
        status: DeviceInfoStatus.failure,
        errorMessage: hwFailure?.message ?? stFailure?.message ?? 'Failed to load device information',
      ));
      return;
    }

    emit(state.copyWith(
      status: DeviceInfoStatus.success,
      hardwareInfo: hwData,
      storageInfo: stData,
    ));

    await _batterySubscription?.cancel();
    _batterySubscription = streamBatteryInfo().listen(
      (batteryInfo) {
        add(BatteryUpdatedEvent(batteryInfo));
      },
    );
  }

  void _onPauseBatteryTracking(
    PauseBatteryTrackingEvent event,
    Emitter<DeviceInfoState> emit,
  ) {
    _batterySubscription?.cancel();
    _batterySubscription = null;
  }

  void _onBatteryUpdated(
    BatteryUpdatedEvent event,
    Emitter<DeviceInfoState> emit,
  ) {
    emit(state.copyWith(batteryInfo: event.batteryInfo));
  }

  @override
  Future<void> close() {
    _batterySubscription?.cancel();
    return super.close();
  }
}
