import '../../domain/entities/nlp_parsed_result.dart';
import '../../domain/entities/tag.dart';

class NlpParserService {
  const NlpParserService();

  NlpParsedResult parse(String input) {
    if (input.trim().isEmpty) {
      return const NlpParsedResult(title: '');
    }

    String workingText = input;

    // 1. Parse priority: !!1 to !!4
    int priority = 4; // default
    final priorityRegex = RegExp(r'!!([1-4])');
    final priorityMatch = priorityRegex.firstMatch(workingText);
    if (priorityMatch != null) {
      priority = int.parse(priorityMatch.group(1)!);
      workingText = workingText.replaceFirst(priorityMatch.group(0)!, '');
    }

    // 2. Parse tags: #tagname
    final List<Tag> tags = [];
    final tagRegex = RegExp(r'#([a-zA-Z0-9_\-]+)');
    final tagMatches = tagRegex.allMatches(workingText);
    for (final match in tagMatches) {
      tags.add(Tag(match.group(1)!));
    }
    workingText = workingText.replaceAll(tagRegex, '');

    // 3. Parse date and time
    DateTime? dueDate;
    final now = DateTime.now();

    // Check "today" / "tomorrow"
    final dateKeywordRegex = RegExp(
      r'\b(today|tomorrow)\b',
      caseSensitive: false,
    );
    final dateKeywordMatch = dateKeywordRegex.firstMatch(workingText);

    DateTime baseDate = now;
    bool dateFound = false;

    if (dateKeywordMatch != null) {
      dateFound = true;
      final keyword = dateKeywordMatch.group(1)!.toLowerCase();
      if (keyword == 'tomorrow') {
        baseDate = now.add(const Duration(days: 1));
      } else {
        baseDate = now; // today
      }
      workingText = workingText.replaceFirst(dateKeywordMatch.group(0)!, '');
    } else {
      // Check weekday keywords
      final weekdays = {
        'monday': DateTime.monday,
        'tuesday': DateTime.tuesday,
        'wednesday': DateTime.wednesday,
        'thursday': DateTime.thursday,
        'friday': DateTime.friday,
        'saturday': DateTime.saturday,
        'sunday': DateTime.sunday,
      };

      final weekdayRegex = RegExp(
        r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
        caseSensitive: false,
      );
      final weekdayMatch = weekdayRegex.firstMatch(workingText);
      if (weekdayMatch != null) {
        dateFound = true;
        final targetDay = weekdays[weekdayMatch.group(1)!.toLowerCase()]!;
        int daysToAdd = targetDay - now.weekday;
        if (daysToAdd <= 0) {
          daysToAdd += 7; // next week's day
        }
        baseDate = now.add(Duration(days: daysToAdd));
        workingText = workingText.replaceFirst(weekdayMatch.group(0)!, '');
      }
    }

    // Check time: "at 5pm", "at 9am", "at 17:00", "at 17:30"
    final timeRegex = RegExp(
      r'at\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?',
      caseSensitive: false,
    );
    final timeMatch = timeRegex.firstMatch(workingText);

    int hour = 9; // default 9:00 if date is set but no time
    int minute = 0;

    if (timeMatch != null) {
      dateFound = true; // if they specified a time, imply today or target day
      final rawHour = int.parse(timeMatch.group(1)!);
      final rawMinute = timeMatch.group(2) != null ? int.parse(timeMatch.group(2)!) : 0;
      final amPm = timeMatch.group(3)?.toLowerCase();

      hour = rawHour;
      minute = rawMinute;

      if (amPm == 'pm' && hour < 12) {
        hour += 12;
      } else if (amPm == 'am' && hour == 12) {
        hour = 0;
      }

      workingText = workingText.replaceFirst(timeMatch.group(0)!, '');
    }

    if (dateFound) {
      dueDate = DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
    }

    // Clean up extra whitespaces in title
    String title = workingText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (title.isEmpty) {
      title = 'New Task';
    }

    return NlpParsedResult(
      title: title,
      dueDate: dueDate,
      priority: priority,
      tags: tags,
    );
  }
}
