import 'package:flutter_test/flutter_test.dart';
import 'package:Aizen/features/todo/data/services/nlp_parser_service.dart';
import 'package:Aizen/features/todo/domain/entities/tag.dart';

void main() {
  const parser = NlpParserService();

  group('NlpParserService Tests', () {
    test('should parse priority, tags, and date/time tomorrow at 5pm', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      final result = parser.parse('Review Flutter code tomorrow at 5pm !!1 #work');

      expect(result.title, 'Review Flutter code');
      expect(result.priority, 1);
      expect(result.tags, const [Tag('work')]);
      expect(result.dueDate, isNotNull);
      expect(result.dueDate!.year, tomorrow.year);
      expect(result.dueDate!.month, tomorrow.month);
      expect(result.dueDate!.day, tomorrow.day);
      expect(result.dueDate!.hour, 17);
      expect(result.dueDate!.minute, 0);
    });

    test('should parse priority, tags, and default time today', () {
      final now = DateTime.now();

      final result = parser.parse('Send email today !!2 #personal');

      expect(result.title, 'Send email');
      expect(result.priority, 2);
      expect(result.tags, const [Tag('personal')]);
      expect(result.dueDate, isNotNull);
      expect(result.dueDate!.year, now.year);
      expect(result.dueDate!.month, now.month);
      expect(result.dueDate!.day, now.day);
      expect(result.dueDate!.hour, 9); // default hour
      expect(result.dueDate!.minute, 0);
    });

    test('should parse plain text with no markers', () {
      final result = parser.parse('Buy milk');

      expect(result.title, 'Buy milk');
      expect(result.priority, 4);
      expect(result.tags, isEmpty);
      expect(result.dueDate, isNull);
    });

    test('should parse weekday with multiple tags and 24h/am/pm times', () {
      final result = parser.parse('Clean room monday at 10am !!3 #home #chore');

      expect(result.title, 'Clean room');
      expect(result.priority, 3);
      expect(result.tags, const [Tag('home'), Tag('chore')]);
      expect(result.dueDate, isNotNull);
      expect(result.dueDate!.hour, 10);
      expect(result.dueDate!.minute, 0);
    });
  });
}
