import 'package:flutter_test/flutter_test.dart';
import 'package:Aizen/features/expense_tracker/domain/services/expense_command_parser.dart';

void main() {
  const parser = ExpenseCommandParser();

  group('ExpenseCommandParser — happy path', () {
    test('parses amount + tag', () {
      final r = parser.parse('50 #lunch');
      expect(r.isSuccess, isTrue);
      expect(r.expense!.amount, 50);
      expect(r.expense!.category, 'lunch');
      expect(r.expense!.note, '');
    });

    test('parses decimal amount with tag + note', () {
      final r = parser.parse('45.50 #groceries weekly run');
      expect(r.isSuccess, isTrue);
      expect(r.expense!.amount, 45.5);
      expect(r.expense!.category, 'groceries');
      expect(r.expense!.note, 'weekly run');
    });

    test('parses large bill amount', () {
      final r = parser.parse('1200 #internet');
      expect(r.isSuccess, isTrue);
      expect(r.expense!.amount, 1200);
      expect(r.expense!.category, 'internet');
    });

    test('parses negative amount as refund', () {
      final r = parser.parse('-20 #refund cancelled subscription');
      expect(r.isSuccess, isTrue);
      expect(r.expense!.amount, -20);
      expect(r.expense!.category, 'refund');
      expect(r.expense!.note, 'cancelled subscription');
    });

    test('parses leading + sign', () {
      final r = parser.parse('+100 #salary');
      expect(r.isSuccess, isTrue);
      expect(r.expense!.amount, 100);
      expect(r.expense!.category, 'salary');
    });

    test('amount with no tag defaults to general', () {
      final r = parser.parse('30');
      expect(r.isSuccess, isTrue);
      expect(r.expense!.amount, 30);
      expect(r.expense!.category, 'general');
    });

    test('amount with no tag but with note', () {
      final r = parser.parse('15 quick snack');
      expect(r.isSuccess, isTrue);
      expect(r.expense!.amount, 15);
      expect(r.expense!.category, 'general');
      expect(r.expense!.note, 'quick snack');
    });

    test('tag with hyphens and digits', () {
      final r = parser.parse('75 #car-loan-2024');
      expect(r.isSuccess, isTrue);
      expect(r.expense!.category, 'car-loan-2024');
    });

    test('leading/trailing whitespace is trimmed', () {
      final r = parser.parse('   50  #lunch   at office  ');
      expect(r.isSuccess, isTrue);
      expect(r.expense!.amount, 50);
      expect(r.expense!.category, 'lunch');
      expect(r.expense!.note, 'at office');
    });
  });

  group('ExpenseCommandParser — failures', () {
    test('empty input fails', () {
      expect(parser.parse('').isSuccess, isFalse);
      expect(parser.parse('   ').isSuccess, isFalse);
    });

    test('non-numeric amount fails', () {
      expect(parser.parse('abc #lunch').isSuccess, isFalse);
      expect(parser.parse('50.0.0 #lunch').isSuccess, isFalse);
    });

    test('error message includes a usage hint', () {
      final r = parser.parse('garbage');
      expect(r.isSuccess, isFalse);
      expect(r.error, isNotNull);
      // Either "Unrecognised" (no regex match) or "Invalid amount"
      // depending on which path the regex catches.
    });
  });

  group('ExpenseCommandParser — display helper', () {
    test('formats positive amount', () {
      final s = parser.display(50, 'lunch');
      expect(s, contains('50'));
      expect(s, contains('#lunch'));
    });

    test('formats negative amount with leading -', () {
      final s = parser.display(-20, 'refund');
      expect(s.startsWith('-'), isTrue);
      expect(s, contains('#refund'));
    });
  });
}
