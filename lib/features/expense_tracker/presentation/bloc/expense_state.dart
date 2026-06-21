import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/bill_reminder.dart';

enum ExpenseStatus { initial, loading, success, failure }

class ExpenseState extends Equatable {
  final ExpenseStatus status;
  final List<ExpenseEntry> expenses;
  final List<BillReminder> bills;
  final String? message;
  final String? errorMessage;

  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.expenses = const [],
    this.bills = const [],
    this.message,
    this.errorMessage,
  });

  /// Today's total spend (negative amounts are refunds/income).
  double get todaySpend {
    final now = DateTime.now();
    return expenses
        .where((e) =>
            e.createdAt.year == now.year &&
            e.createdAt.month == now.month &&
            e.createdAt.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// This month's total spend.
  double get monthSpend {
    final now = DateTime.now();
    return expenses
        .where((e) =>
            e.createdAt.year == now.year && e.createdAt.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// All-time total.
  double get totalSpend =>
      expenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Bills due within the next [days] days.
  List<BillReminder> billsDueWithin(int days) {
    final now = DateTime.now();
    return bills
        .where((b) => b.enabled && b.daysUntilDue(now) <= days && b.daysUntilDue(now) >= -1)
        .toList();
  }

  ExpenseState copyWith({
    ExpenseStatus? status,
    List<ExpenseEntry>? expenses,
    List<BillReminder>? bills,
    String? message,
    String? errorMessage,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      bills: bills ?? this.bills,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, expenses, bills, message, errorMessage];
}
