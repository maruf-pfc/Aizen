import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/device_info_bloc.dart';
import '../bloc/device_info_event.dart';
import '../bloc/device_info_state.dart';
import '../../domain/entities/hardware_info.dart';
import '../../domain/entities/battery_info.dart';
import '../../domain/entities/storage_info.dart';
import '../widgets/battery_info_panel.dart';
import '../widgets/hardware_info_panel.dart';
import '../widgets/storage_info_panel.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  @override
  void initState() {
    super.initState();
    context.read<DeviceInfoBloc>().add(LoadDeviceInfoEvent());
  }

  @override
  void dispose() {
    context.read<DeviceInfoBloc>().add(PauseBatteryTrackingEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Aizen Specifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            onPressed: () {
              context.read<DeviceInfoBloc>().add(LoadDeviceInfoEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          if (state.status == DeviceInfoStatus.loading || state.status == DeviceInfoStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C4DFF),
                strokeWidth: 2,
              ),
            );
          } else if (state.status == DeviceInfoStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'An error occurred while loading specifications.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7C4DFF)),
                        foregroundColor: const Color(0xFF7C4DFF),
                      ),
                      onPressed: () {
                        context.read<DeviceInfoBloc>().add(LoadDeviceInfoEvent());
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;

              final hardwarePanel = BlocSelector<DeviceInfoBloc, DeviceInfoState, HardwareInfo?>(
                selector: (state) => state.hardwareInfo,
                builder: (context, hw) {
                  return hw != null ? HardwareInfoPanel(info: hw) : const SizedBox.shrink();
                },
              );

              final batteryPanel = BlocSelector<DeviceInfoBloc, DeviceInfoState, BatteryInfo?>(
                selector: (state) => state.batteryInfo,
                builder: (context, bt) {
                  return bt != null
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: BatteryInfoPanel(info: bt),
                        )
                      : const SizedBox.shrink();
                },
              );

              final storagePanel = BlocSelector<DeviceInfoBloc, DeviceInfoState, StorageInfo?>(
                selector: (state) => state.storageInfo,
                builder: (context, st) {
                  return st != null ? StorageInfoPanel(info: st) : const SizedBox.shrink();
                },
              );

              if (isWide) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          child: hardwarePanel,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              batteryPanel,
                              storagePanel,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      hardwarePanel,
                      const SizedBox(height: 16),
                      batteryPanel,
                      storagePanel,
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
