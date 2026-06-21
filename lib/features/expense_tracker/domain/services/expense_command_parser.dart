/// Aizen v1.6.0 — Expense command parser.
///
/// Parses terse command-input strings like:
///   `50 #lunch`
///   `1200 #internet`
///   `45.50 #groceries weekly run`
///   `-20 #refund cancelled subscription`
///   `30 #coffee at the office`
///
/// Output is a structured [ParsedExpense] record ready to be inserted into
/// the ledger. Designed to be pure-Dart and unit-testable with zero Flutter
/// dependencies.
library aizen.expense_tracker.command_parser;

class ParsedExpense {
  final double amount;
  final String category;
  final String note;

  const ParsedExpense({
    required this.amount,
    required this.category,
    required this.note,
  });

  @override
  String toString() => 'ParsedExpense(amount=$amount, category="$category", note="$note")';
}

class ExpenseParseResult {
  final ParsedExpense? expense;
  final String? error;

  const ExpenseParseResult._({this.expense, this.error});

  factory ExpenseParseResult.success(ParsedExpense e) =>
      ExpenseParseResult._(expense: e);

  factory ExpenseParseResult.failure(String message) =>
      ExpenseParseResult._(error: message);

  bool get isSuccess => expense != null;
}

class ExpenseCommandParser {
  const ExpenseCommandParser();

  /// Parse a single command line. Returns null on failure (with error).
  ExpenseParseResult parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return ExpenseParseResult.failure('Empty input');
    }

    // Match: <amount> [#category] [optional note]
    // Examples:
    //   50 #lunch
    //   45.50 #groceries weekly run
    //   -20 #refund cancelled
    //   +100 #salary
    final m = RegExp(
      r'^([+-]?\d+(?:\.\d+)?)(?:\s+|(?=#)|$)(?:#([A-Za-z0-9_\-]+))?\s*(.*)$',
    ).firstMatch(trimmed);

    if (m == null) {
      return ExpenseParseResult.failure('Unrecognised format. Try: 50 #lunch');
    }

    final amountStr = m.group(1)!;
    final catRaw = m.group(2);
    final noteRaw = m.group(3) ?? '';

    final amount = double.tryParse(amountStr);
    if (amount == null) {
      return ExpenseParseResult.failure('Invalid amount: $amountStr');
    }

    final category = (catRaw == null || catRaw.isEmpty)
        ? 'general'
        : catRaw.toLowerCase();
    final note = noteRaw.trim();

    return ExpenseParseResult.success(ParsedExpense(
      amount: amount,
      category: category,
      note: note,
    ));
  }

  /// Generate a friendly display string for a ledger row, e.g.
  /// `-৳1200  #internet`
  String display(double amount, String category) {
    final sign = amount < 0 ? '-' : '';
    return '$sign\u{09F3}${amount.abs().toStringAsFixed(2)}  #$category';
  }
}
