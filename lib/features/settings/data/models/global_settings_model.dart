import '../../domain/entities/global_settings.dart';

class GlobalSettingsModel extends GlobalSettings {
  const GlobalSettingsModel({
    super.themeMode = 'amoled',
    super.usageStatsGranted = false,
    super.systemOverlayGranted = false,
  });

  factory GlobalSettingsModel.fromJson(Map<String, dynamic> json) {
    return GlobalSettingsModel(
      themeMode: json['themeMode'] as String? ?? 'amoled',
      usageStatsGranted: json['usageStatsGranted'] as bool? ?? false,
      systemOverlayGranted: json['systemOverlayGranted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'usageStatsGranted': usageStatsGranted,
      'systemOverlayGranted': systemOverlayGranted,
    };
  }

  factory GlobalSettingsModel.fromEntity(GlobalSettings entity) {
    return GlobalSettingsModel(
      themeMode: entity.themeMode,
      usageStatsGranted: entity.usageStatsGranted,
      systemOverlayGranted: entity.systemOverlayGranted,
    );
  }
}
