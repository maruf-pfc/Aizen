import 'package:equatable/equatable.dart';

class GlobalSettings extends Equatable {
  final String themeMode; // 'amoled', 'dark', 'light'
  final bool usageStatsGranted;
  final bool systemOverlayGranted;

  const GlobalSettings({
    this.themeMode = 'amoled',
    this.usageStatsGranted = false,
    this.systemOverlayGranted = false,
  });

  GlobalSettings copyWith({
    String? themeMode,
    bool? usageStatsGranted,
    bool? systemOverlayGranted,
  }) {
    return GlobalSettings(
      themeMode: themeMode ?? this.themeMode,
      usageStatsGranted: usageStatsGranted ?? this.usageStatsGranted,
      systemOverlayGranted: systemOverlayGranted ?? this.systemOverlayGranted,
    );
  }

  @override
  List<Object?> get props => [themeMode, usageStatsGranted, systemOverlayGranted];
}
