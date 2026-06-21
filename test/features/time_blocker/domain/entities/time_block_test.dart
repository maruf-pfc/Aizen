import 'package:flutter_test/flutter_test.dart';
import 'package:Aizen/features/time_blocker/domain/entities/time_block.dart';

void main() {
  group('TimeBlock — basic invariants', () {
    test('durationHours = endHour - startHour', () {
      final b = TimeBlock(
        id: 'x',
        label: 'Work',
        startHour: 9,
        endHour: 12,
        color: '7C4DFF',
        createdAt: DateTime(2024, 6, 21),
      );
      expect(b.durationHours, 3);
    });

    test('isNow returns true when current hour is within block', () {
      final b = TimeBlock(
        id: 'x',
        label: 'Work',
        startHour: 9,
        endHour: 17,
        color: '7C4DFF',
        createdAt: DateTime(2024, 6, 21),
      );
      expect(b.isNow(DateTime(2024, 6, 21, 9, 0)), isTrue);
      expect(b.isNow(DateTime(2024, 6, 21, 12, 30)), isTrue);
      expect(b.isNow(DateTime(2024, 6, 21, 16, 59)), isTrue);
      expect(b.isNow(DateTime(2024, 6, 21, 8, 59)), isFalse);
      expect(b.isNow(DateTime(2024, 6, 21, 17, 0)), isFalse);
    });

    test('elapsedFraction is 0 before start, 1 after end, in (0,1) inside', () {
      final b = TimeBlock(
        id: 'x',
        label: 'Work',
        startHour: 9,
        endHour: 17,
        color: '7C4DFF',
        createdAt: DateTime(2024, 6, 21),
      );
      expect(b.elapsedFraction(DateTime(2024, 6, 21, 8)), 0);
      expect(b.elapsedFraction(DateTime(2024, 6, 21, 18)), 1);
      final half = b.elapsedFraction(DateTime(2024, 6, 21, 13));
      expect(half, closeTo(0.5, 1e-9));
    });
  });

  group('TimeBlock — JSON round-trip', () {
    test('toJson / fromJson preserve all fields', () {
      final original = TimeBlock(
        id: 'tb1',
        label: 'Deep Work Coding',
        startHour: 9,
        endHour: 11,
        color: '00E676',
        createdAt: DateTime(2024, 6, 21, 9),
        completed: true,
      );
      final json = original.toJson();
      final restored = TimeBlock.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.label, original.label);
      expect(restored.startHour, original.startHour);
      expect(restored.endHour, original.endHour);
      expect(restored.color, original.color);
      expect(restored.createdAt, original.createdAt);
      expect(restored.completed, original.completed);
    });
  });
}
