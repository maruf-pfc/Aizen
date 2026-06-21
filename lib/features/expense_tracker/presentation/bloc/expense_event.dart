import 'package:equatable/equatable.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}

class LoadExpenseDataEvent extends ExpenseEvent {
  const LoadExpenseDataEvent();
}

class AddExpenseCommandEvent extends ExpenseEvent {
  final String rawCommand;
  const AddExpenseCommandEvent(this.rawCommand);

  @override
  List<Object?> get props => [rawCommand];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String id;
  const DeleteExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearAllExpensesEvent extends ExpenseEvent {
  const ClearAllExpensesEvent();
}

class AddBillEvent extends ExpenseEvent {
  final String title;
  final double amount;
  final int dueDayOfMonth;
  final String category;
  const AddBillEvent({
    required this.title,
    required this.amount,
    required this.dueDayOfMonth,
    required this.category,
  });

  @override
  List<Object?> get props => [title, amount, dueDayOfMonth, category];
}

class MarkBillPaidEvent extends ExpenseEvent {
  final String id;
  const MarkBillPaidEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteBillEvent extends ExpenseEvent {
  final String id;
  const DeleteBillEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleBillEnabledEvent extends ExpenseEvent {
  final String id;
  const ToggleBillEnabledEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RescheduleBillRemindersEvent extends ExpenseEvent {
  const RescheduleBillRemindersEvent();
}
