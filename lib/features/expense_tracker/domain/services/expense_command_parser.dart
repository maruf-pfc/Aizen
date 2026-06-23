// Aizen v1.5.0 — Expense command parser.
//
// Parses terse command-input strings like:
//   $50 #lunch
//   ৳1200 #internet
//   -€20 #refund cancelled subscription
//   +£100 #salary
//
// Output is a structured ParsedExpense record ready to be inserted into
// the ledger. Designed to be pure-Dart and unit-testable with zero Flutter
// dependencies.

class ParsedExpense {
  final double amount;
  final String category;
  final String note;
  final String currency;

  const ParsedExpense({
    required this.amount,
    required this.category,
    required this.note,
    this.currency = '\u{09F3}',
  });

  @override
  String toString() => 'ParsedExpense(amount=$amount, category="$category", note="$note", currency="$currency")';
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

    // Match: [optional currency] [optional sign] [optional currency] <amount> [#category] [optional note]
    final m = RegExp(
      r'^([\$৳£€¥]?)\s*([+-]?)\s*([\$৳£€¥]?)\s*(\d+(?:\.\d+)?)(?:\s+|(?=#)|$)(?:#([A-Za-z0-9_\-]+))?\s*(.*)$',
    ).firstMatch(trimmed);

    if (m == null) {
      return ExpenseParseResult.failure('Unrecognised format. Try: \$50 #lunch');
    }

    final currency1 = m.group(1) ?? '';
    final signRaw = m.group(2) ?? '';
    final currency2 = m.group(3) ?? '';
    final amountStr = m.group(4)!;
    final catRaw = m.group(5);
    final noteRaw = m.group(6) ?? '';

    final currency = currency1.isNotEmpty ? currency1 : (currency2.isNotEmpty ? currency2 : '\u{09F3}');
    final amountVal = double.tryParse(amountStr);
    if (amountVal == null) {
      return ExpenseParseResult.failure('Invalid amount: $amountStr');
    }

    final double amount = (signRaw == '-') ? -amountVal : amountVal;
    final category = (catRaw == null || catRaw.isEmpty)
        ? 'general'
        : catRaw.toLowerCase();
    final note = noteRaw.trim();

    return ExpenseParseResult.success(ParsedExpense(
      amount: amount,
      category: category,
      note: note,
      currency: currency,
    ));
  }

  /// Generate a friendly display string for a ledger row, e.g.
  /// `-৳1200  #internet`
  String display(double amount, String category, [String currency = '\u{09F3}']) {
    final sign = amount < 0 ? '-' : '';
    return '$sign$currency${amount.abs().toStringAsFixed(2)}  #$category';
  }
}
