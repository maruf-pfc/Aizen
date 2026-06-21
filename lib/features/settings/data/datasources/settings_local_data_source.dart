import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/global_settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<GlobalSettingsModel> getSettings();
  Future<void> saveSettings(GlobalSettingsModel settings);
  Future<void> clearCache();
  Future<void> optimizeDatabase();
  Future<String> exportData();
  Future<void> importData(String jsonString);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _settingsKey = 'aizen_global_settings_v1';

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<GlobalSettingsModel> getSettings() async {
    final jsonString = sharedPreferences.getString(_settingsKey);
    if (jsonString == null) {
      return const GlobalSettingsModel();
    }
    try {
      return GlobalSettingsModel.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );
    } catch (_) {
      return const GlobalSettingsModel();
    }
  }

  @override
  Future<void> saveSettings(GlobalSettingsModel settings) async {
    await sharedPreferences.setString(
      _settingsKey,
      json.encode(settings.toJson()),
    );
  }

  @override
  Future<void> clearCache() async {
    final keys = sharedPreferences.getKeys();
    for (final key in keys) {
      if (key != _settingsKey) {
        await sharedPreferences.remove(key);
      }
    }
  }

  @override
  Future<void> optimizeDatabase() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<String> exportData() async {
    final Map<String, dynamic> allData = {};
    final keys = sharedPreferences.getKeys();
    for (final key in keys) {
      final val = sharedPreferences.get(key);
      if (val != null) {
        allData[key] = val;
      }
    }
    return json.encode(allData);
  }

  @override
  Future<void> importData(String jsonString) async {
    final Map<String, dynamic> data =
        json.decode(jsonString) as Map<String, dynamic>;
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is String) {
        await sharedPreferences.setString(entry.key, value);
      } else if (value is bool) {
        await sharedPreferences.setBool(entry.key, value);
      } else if (value is int) {
        await sharedPreferences.setInt(entry.key, value);
      } else if (value is double) {
        await sharedPreferences.setDouble(entry.key, value);
      } else if (value is List) {
        await sharedPreferences.setStringList(
          entry.key,
          value.map((e) => e.toString()).toList(),
        );
      }
    }
  }
}
