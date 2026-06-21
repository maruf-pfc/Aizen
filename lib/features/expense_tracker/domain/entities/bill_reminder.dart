import 'package:equatable/equatable.dart';

/// A recurring bill (rent, utilities, internet, etc.) tracked in the
/// Bill Pay Reminders Ledger.
class BillReminder extends Equatable {
  final String id;
  final String title;
  final double amount;
  final int dueDayOfMonth; // 1..31
  final String category;
  final bool enabled;
  final DateTime lastPaidAt;
  final DateTime nextDueAt;

  const BillReminder({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDayOfMonth,
    required this.category,
    required this.enabled,
    required this.lastPaidAt,
    required this.nextDueAt,
  });

  BillReminder copyWith({
    String? id,
    String? title,
    double? amount,
    int? dueDayOfMonth,
    String? category,
    bool? enabled,
    DateTime? lastPaidAt,
    DateTime? nextDueAt,
  }) {
    return BillReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      lastPaidAt: lastPaidAt ?? this.lastPaidAt,
      nextDueAt: nextDueAt ?? this.nextDueAt,
    );
  }

  factory BillReminder.fromJson(Map<String, dynamic> json) {
    return BillReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDayOfMonth: (json['dueDayOfMonth'] as num).toInt(),
      category: json['category'] as String,
      enabled: json['enabled'] as bool? ?? true,
      lastPaidAt: json['lastPaidAt'] != null
          ? DateTime.parse(json['lastPaidAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
      nextDueAt: DateTime.parse(json['nextDueAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'dueDayOfMonth': dueDayOfMonth,
        'category': category,
        'enabled': enabled,
        'lastPaidAt': lastPaidAt.toIso8601String(),
        'nextDueAt': nextDueAt.toIso8601String(),
      };

  /// Returns the number of days until [nextDueAt] from [now]. Negative if overdue.
  int daysUntilDue(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(nextDueAt.year, nextDueAt.month, nextDueAt.day);
    return due.difference(today).inDays;
  }

  /// Advance the nextDueAt to the next month (or month after that if still
  /// in the past relative to [now]).
  BillReminder rollForward(DateTime now) {
    var next = nextDueAt;
    while (next.isBefore(DateTime(now.year, now.month, 1))) {
      next = _addMonth(next);
    }
    // Adjust day-of-month to the configured due day, clamping month length.
    next = _withDueDay(next, dueDayOfMonth);
    return copyWith(nextDueAt: next);
  }

  DateTime _addMonth(DateTime d) {
    final newMonth = d.month == 12 ? 1 : d.month + 1;
    final newYear = d.month == 12 ? d.year + 1 : d.year;
    final dom = _clampDay(newYear, newMonth, dueDayOfMonth);
    return DateTime(newYear, newMonth, dom);
  }

  DateTime _withDueDay(DateTime d, int day) {
    final dom = _clampDay(d.year, d.month, day);
    return DateTime(d.year, d.month, dom);
  }

  int _clampDay(int year, int month, int day) {
    if (day < 1) return 1;
    final firstNext = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    final lastDay = firstNext.subtract(const Duration(days: 1)).day;
    return day > lastDay ? lastDay : day;
  }

  @override
  List<Object?> get props =>
      [id, title, amount, dueDayOfMonth, category, enabled, lastPaidAt, nextDueAt];
}
