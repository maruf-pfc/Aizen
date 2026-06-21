import 'package:equatable/equatable.dart';

/// Threshold mode controls when the App Blocker should aggressively
/// lock the user out of blacklisted apps.
enum ThresholdMode {
  /// Always block — every attempt to launch a blacklisted app is denied.
  always,

  /// Block only when daily screen-time exceeds the threshold minutes.
  dailyMinutes,

  /// Block only during a configured time window (e.g. 22:00 - 06:00).
  timeWindow,
}

class AppBlockerState extends Equatable {
  final Set<String> blockedPackages;
  final ThresholdMode mode;
  final int dailyThresholdMinutes;
  final int windowStartHour;   // 0..23
  final int windowEndHour;     // 1..24

  const AppBlockerState({
    this.blockedPackages = const {},
    this.mode = ThresholdMode.always,
    this.dailyThresholdMinutes = 180,
    this.windowStartHour = 22,
    this.windowEndHour = 6,
  });

  /// True if a launch attempt at [now] with [minutesUsedToday] should be
  /// blocked, given the current state.
  bool shouldBlock({required DateTime now, required int minutesUsedToday}) {
    switch (mode) {
      case ThresholdMode.always:
        return true;
      case ThresholdMode.dailyMinutes:
        return minutesUsedToday >= dailyThresholdMinutes;
      case ThresholdMode.timeWindow:
        final h = now.hour;
        if (windowStartHour < windowEndHour) {
          return h >= windowStartHour && h < windowEndHour;
        }
        // Window crosses midnight (e.g. 22 - 6).
        return h >= windowStartHour || h < windowEndHour;
    }
  }

  AppBlockerState copyWith({
    Set<String>? blockedPackages,
    ThresholdMode? mode,
    int? dailyThresholdMinutes,
    int? windowStartHour,
    int? windowEndHour,
  }) {
    return AppBlockerState(
      blockedPackages: blockedPackages ?? this.blockedPackages,
      mode: mode ?? this.mode,
      dailyThresholdMinutes: dailyThresholdMinutes ?? this.dailyThresholdMinutes,
      windowStartHour: windowStartHour ?? this.windowStartHour,
      windowEndHour: windowEndHour ?? this.windowEndHour,
    );
  }

  @override
  List<Object?> get props => [
        blockedPackages,
        mode,
        dailyThresholdMinutes,
        windowStartHour,
        windowEndHour,
      ];
}
