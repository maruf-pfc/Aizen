import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:Aizen/features/focus_guardian/presentation/bloc/app_blocker_bloc.dart';
import 'package:Aizen/features/focus_guardian/presentation/bloc/app_blocker_event.dart';
import 'package:Aizen/features/focus_guardian/presentation/bloc/app_blocker_state.dart';

/// v1.5.0 — Tests for the App Blocker threshold state mutations.
void main() {
  group('AppBlockerBloc — threshold updates', () {
    late AppBlockerBloc bloc;

    setUp(() {
      bloc = AppBlockerBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has default thresholds', () {
      expect(bloc.state.mode, ThresholdMode.always);
      expect(bloc.state.dailyThresholdMinutes, 180);
      expect(bloc.state.windowStartHour, 22);
      expect(bloc.state.windowEndHour, 6);
      expect(bloc.state.blockedPackages, isEmpty);
    });

    blocTest<AppBlockerBloc, AppBlockerState>(
      'UpdateDailyThresholdEvent sets the threshold',
      build: () => bloc,
      act: (b) => b.add(const UpdateDailyThresholdEvent(240)),
      expect: () => [
        isA<AppBlockerState>()
            .having((s) => s.dailyThresholdMinutes, 'threshold', 240),
      ],
    );

    blocTest<AppBlockerBloc, AppBlockerState>(
      'UpdateDailyThresholdEvent rejects out-of-range values',
      build: () => bloc,
      act: (b) => b.add(const UpdateDailyThresholdEvent(-10)),
      expect: () => [],
    );

    blocTest<AppBlockerBloc, AppBlockerState>(
      'UpdateDailyThresholdEvent rejects > 1440',
      build: () => bloc,
      act: (b) => b.add(const UpdateDailyThresholdEvent(2000)),
      expect: () => [],
    );

    blocTest<AppBlockerBloc, AppBlockerState>(
      'ChangeThresholdModeEvent switches mode',
      build: () => bloc,
      act: (b) => b.add(const ChangeThresholdModeEvent(ThresholdMode.timeWindow)),
      expect: () => [
        isA<AppBlockerState>()
            .having((s) => s.mode, 'mode', ThresholdMode.timeWindow),
      ],
    );

    blocTest<AppBlockerBloc, AppBlockerState>(
      'UpdateWindowStartHourEvent clamps to 0..23',
      build: () => bloc,
      act: (b) => b.add(const UpdateWindowStartHourEvent(23)),
      expect: () => [
        isA<AppBlockerState>()
            .having((s) => s.windowStartHour, 'start', 23),
      ],
    );

    blocTest<AppBlockerBloc, AppBlockerState>(
      'UpdateWindowStartHourEvent rejects 24',
      build: () => bloc,
      act: (b) => b.add(const UpdateWindowStartHourEvent(24)),
      expect: () => [],
    );

    blocTest<AppBlockerBloc, AppBlockerState>(
      'UpdateWindowEndHourEvent accepts 24',
      build: () => bloc,
      act: (b) => b.add(const UpdateWindowEndHourEvent(24)),
      expect: () => [
        isA<AppBlockerState>()
            .having((s) => s.windowEndHour, 'end', 24),
      ],
    );
  });

  group('AppBlockerBloc — package list mutations', () {
    late AppBlockerBloc bloc;

    setUp(() {
      bloc = AppBlockerBloc();
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<AppBlockerBloc, AppBlockerState>(
      'TogglePackageBlockedEvent adds a package',
      build: () => bloc,
      act: (b) =>
          b.add(const TogglePackageBlockedEvent('com.facebook.katana')),
      expect: () => [
        isA<AppBlockerState>().having(
            (s) => s.blockedPackages.contains('com.facebook.katana'),
            'package added',
            true),
      ],
    );

    blocTest<AppBlockerBloc, AppBlockerState>(
      'TogglePackageBlockedEvent removes an existing package',
      build: () => AppBlockerBloc(const AppBlockerState(
        blockedPackages: {'com.facebook.katana'},
      )),
      act: (b) =>
          b.add(const TogglePackageBlockedEvent('com.facebook.katana')),
      expect: () => [
        isA<AppBlockerState>().having(
            (s) => s.blockedPackages.contains('com.facebook.katana'),
            'package removed',
            false),
      ],
    );

    blocTest<AppBlockerBloc, AppBlockerState>(
      'SetBlockedPackagesEvent replaces the entire set',
      build: () => bloc,
      act: (b) => b.add(const SetBlockedPackagesEvent({
        'com.facebook.katana',
        'com.instagram.android',
        'com.zhiliaoapp.musically',
      })),
      expect: () => [
        isA<AppBlockerState>().having(
            (s) => s.blockedPackages.length, 'count', 3),
      ],
    );
  });

  group('AppBlockerState — shouldBlock decision logic', () {
    test('always mode blocks unconditionally', () {
      const s = AppBlockerState(mode: ThresholdMode.always);
      expect(
          s.shouldBlock(
              now: DateTime(2024, 6, 21, 3, 30), minutesUsedToday: 0),
          isTrue);
    });

    test('dailyMinutes mode blocks once threshold crossed', () {
      const s = AppBlockerState(
        mode: ThresholdMode.dailyMinutes,
        dailyThresholdMinutes: 120,
      );
      expect(
          s.shouldBlock(
              now: DateTime(2024, 6, 21, 12),
              minutesUsedToday: 100),
          isFalse);
      expect(
          s.shouldBlock(
              now: DateTime(2024, 6, 21, 14),
              minutesUsedToday: 120),
          isTrue);
      expect(
          s.shouldBlock(
              now: DateTime(2024, 6, 21, 18),
              minutesUsedToday: 300),
          isTrue);
    });

    test('timeWindow mode blocks inside the window (non-crossing)', () {
      const s = AppBlockerState(
        mode: ThresholdMode.timeWindow,
        windowStartHour: 9,
        windowEndHour: 17,
      );
      expect(s.shouldBlock(now: DateTime(2024, 6, 21, 10), minutesUsedToday: 0),
          isTrue);
      expect(s.shouldBlock(now: DateTime(2024, 6, 21, 8), minutesUsedToday: 0),
          isFalse);
      expect(s.shouldBlock(now: DateTime(2024, 6, 21, 18), minutesUsedToday: 0),
          isFalse);
    });

    test('timeWindow mode blocks across midnight (e.g. 22 - 6)', () {
      const s = AppBlockerState(
        mode: ThresholdMode.timeWindow,
        windowStartHour: 22,
        windowEndHour: 6,
      );
      expect(s.shouldBlock(now: DateTime(2024, 6, 21, 23), minutesUsedToday: 0),
          isTrue);
      expect(s.shouldBlock(now: DateTime(2024, 6, 21, 2), minutesUsedToday: 0),
          isTrue);
      expect(s.shouldBlock(now: DateTime(2024, 6, 21, 12), minutesUsedToday: 0),
          isFalse);
    });
  });
}
