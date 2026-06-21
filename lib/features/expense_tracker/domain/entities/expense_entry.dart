import 'package:equatable/equatable.dart';

/// A single expense entry recorded in the inline ledger.
class ExpenseEntry extends Equatable {
  final String id;
  final double amount;
  final String category;
  final String note;
  final DateTime createdAt;

  const ExpenseEntry({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.createdAt,
  });

  ExpenseEntry copyWith({
    String? id,
    double? amount,
    String? category,
    String? note,
    DateTime? createdAt,
  }) {
    return ExpenseEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) {
    return ExpenseEntry(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, amount, category, note, createdAt];
}
