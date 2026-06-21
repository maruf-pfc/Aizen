import 'dart:io' as io;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:storage_space/storage_space.dart';

import '../../domain/entities/battery_info.dart';
import '../models/battery_info_model.dart';
import '../models/hardware_info_model.dart';
import '../models/storage_info_model.dart';

abstract class DeviceInfoLocalDataSource {
  Future<HardwareInfoModel> getHardwareInfo();
  Future<StorageInfoModel> getStorageInfo();
  Stream<BatteryInfoModel> streamBatteryInfo();
}

class DeviceInfoLocalDataSourceImpl implements DeviceInfoLocalDataSource {
  final DeviceInfoPlugin deviceInfoPlugin;
  final Battery battery;

  final io.File _batteryTempFile = io.File('/sys/class/power_supply/battery/temp');
  final io.File _memInfoFile = io.File('/proc/meminfo');

  DeviceInfoLocalDataSourceImpl({
    required this.deviceInfoPlugin,
    required this.battery,
  });

  @override
  Future<HardwareInfoModel> getHardwareInfo() async {
    String model = 'Unknown';
    String manufacturer = 'Unknown';
    String osVersion = 'Unknown';
    String kernelArchitecture = 'Unknown';
    int cpuCores = 1;
    int totalRam = 4096;

    if (kIsWeb) {
      model = 'Web Application';
      manufacturer = 'Web Browser';
      osVersion = 'HTML5 / WASM';
      kernelArchitecture = 'Javascript / WASM';
      cpuCores = 1;
      totalRam = 8192;
    } else {
      cpuCores = io.Platform.numberOfProcessors;
      totalRam = await _getTotalRam();

      if (io.Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        model = androidInfo.model;
        manufacturer = androidInfo.manufacturer;
        osVersion = 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
        kernelArchitecture = androidInfo.supportedAbis.isNotEmpty ? androidInfo.supportedAbis.first : 'Unknown';
      } else if (io.Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        model = iosInfo.name;
        manufacturer = 'Apple';
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
        kernelArchitecture = iosInfo.utsname.machine;
      } else if (io.Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        model = linuxInfo.name;
        manufacturer = linuxInfo.id;
        osVersion = linuxInfo.versionId ?? 'Unknown';
        kernelArchitecture = 'x86_64';
      } else if (io.Platform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        model = macInfo.model;
        manufacturer = 'Apple';
        osVersion = 'macOS ${macInfo.osRelease}';
        kernelArchitecture = macInfo.arch;
      } else if (io.Platform.isWindows) {
        final winInfo = await deviceInfoPlugin.windowsInfo;
        model = winInfo.computerName;
        manufacturer = 'Windows Device';
        osVersion = 'Windows ${winInfo.releaseId}';
        kernelArchitecture = 'x64';
      }
    }

    return HardwareInfoModel(
      model: model,
      manufacturer: manufacturer,
      osVersion: osVersion,
      kernelArchitecture: kernelArchitecture,
      cpuCores: cpuCores,
      totalRamMB: totalRam,
    );
  }

  @override
  Future<StorageInfoModel> getStorageInfo() async {
    if (kIsWeb) {
      // Return mocked storage since LocalStorage/IndexedDB has custom quotas
      return const StorageInfoModel(
        totalBytes: 128 * 1024 * 1024 * 1024, // 128 GB
        freeBytes: 96 * 1024 * 1024 * 1024,  // 96 GB
        usedBytes: 32 * 1024 * 1024 * 1024,  // 32 GB
      );
    }

    final space = await getStorageSpace(
      lowOnSpaceThreshold: 2 * 1024 * 1024 * 1024,
      fractionDigits: 2,
    );
    return StorageInfoModel(
      totalBytes: space.total,
      freeBytes: space.free,
      usedBytes: space.used,
    );
  }

  @override
  Stream<BatteryInfoModel> streamBatteryInfo() async* {
    if (kIsWeb) {
      // Mock web battery stream
      yield const BatteryInfoModel(
        percentage: 100,
        status: ChargingStatus.full,
        health: 'Good',
        temperature: 30.0,
      );
      return;
    }

    try {
      final initialLevel = await battery.batteryLevel;
      final initialState = await battery.batteryState;
      yield await _mapToBatteryModel(initialLevel, initialState);
    } catch (_) {
      yield const BatteryInfoModel(
        percentage: 0,
        status: ChargingStatus.unknown,
        health: 'Unknown',
        temperature: null,
      );
    }

    await for (final state in battery.onBatteryStateChanged) {
      try {
        final level = await battery.batteryLevel;
        yield await _mapToBatteryModel(level, state);
      } catch (_) {
        yield const BatteryInfoModel(
          percentage: 0,
          status: ChargingStatus.unknown,
          health: 'Unknown',
          temperature: null,
        );
      }
    }
  }

  Future<BatteryInfoModel> _mapToBatteryModel(int level, BatteryState state) async {
    ChargingStatus status = ChargingStatus.unknown;
    if (state == BatteryState.charging) {
      status = ChargingStatus.charging;
    } else if (state == BatteryState.discharging) {
      status = ChargingStatus.discharging;
    } else if (state == BatteryState.full) {
      status = ChargingStatus.full;
    }

    double? temp;
    String health = 'Good';

    if (!kIsWeb) {
      if (io.Platform.isAndroid || io.Platform.isLinux) {
        temp = await _readAndroidBatteryTemp();
      }
    }

    return BatteryInfoModel(
      percentage: level,
      status: status,
      health: health,
      temperature: temp,
    );
  }

  Future<double?> _readAndroidBatteryTemp() async {
    try {
      if (await _batteryTempFile.exists()) {
        final content = await _batteryTempFile.readAsString();
        final rawTemp = double.tryParse(content.trim());
        if (rawTemp != null) {
          return rawTemp / 10.0;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<int> _getTotalRam() async {
    try {
      if (io.Platform.isLinux || io.Platform.isAndroid) {
        if (await _memInfoFile.exists()) {
          final lines = await _memInfoFile.readAsLines();
          for (final line in lines) {
            if (line.startsWith('MemTotal:')) {
              final match = RegExp(r'\d+').firstMatch(line);
              if (match != null) {
                final kb = int.parse(match.group(0)!);
                return kb ~/ 1024;
              }
            }
          }
        }
      }
    } catch (_) {}
    return 8192; // 8GB default fallback
  }
}
