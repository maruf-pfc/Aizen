import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lap_model.dart';
import '../models/stopwatch_state_model.dart';

abstract class StopwatchLocalDataSource {
  Future<StopwatchStateModel?> getStopwatchState();
  Future<void> saveStopwatchState(StopwatchStateModel state);
  Future<List<LapModel>?> getLaps();
  Future<void> saveLaps(List<LapModel> laps);
  Future<void> clearData();
}

class StopwatchLocalDataSourceImpl implements StopwatchLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const _stateKey = 'stopwatch_state';
  static const _lapsKey = 'stopwatch_laps';

  const StopwatchLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<StopwatchStateModel?> getStopwatchState() async {
    final jsonString = sharedPreferences.getString(_stateKey);
    if (jsonString != null) {
      return StopwatchStateModel.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );
    }
    return null;
  }

  @override
  Future<void> saveStopwatchState(StopwatchStateModel state) async {
    await sharedPreferences.setString(_stateKey, json.encode(state.toJson()));
  }

  @override
  Future<List<LapModel>?> getLaps() async {
    final jsonString = sharedPreferences.getString(_lapsKey);
    if (jsonString != null) {
      final decodedList = json.decode(jsonString) as List<dynamic>;
      return decodedList
          .map((item) => LapModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  Future<void> saveLaps(List<LapModel> laps) async {
    final encodedList = laps.map((lap) => lap.toJson()).toList();
    await sharedPreferences.setString(_lapsKey, json.encode(encodedList));
  }

  @override
  Future<void> clearData() async {
    await sharedPreferences.remove(_stateKey);
    await sharedPreferences.remove(_lapsKey);
  }
}
