import 'package:equatable/equatable.dart';
import '../../domain/entities/battery_info.dart';

abstract class DeviceInfoEvent extends Equatable {
  const DeviceInfoEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeviceInfoEvent extends DeviceInfoEvent {}

class PauseBatteryTrackingEvent extends DeviceInfoEvent {}

class BatteryUpdatedEvent extends DeviceInfoEvent {
  final BatteryInfo batteryInfo;

  const BatteryUpdatedEvent(this.batteryInfo);

  @override
  List<Object?> get props => [batteryInfo];
}
