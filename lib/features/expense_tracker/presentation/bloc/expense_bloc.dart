import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/bill_reminder.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/services/expense_command_parser.dart';
import '../../services/bill_notification_service.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _repository;
  final ExpenseCommandParser _parser;
  final BillNotificationService _notifications;

  ExpenseBloc({
    required ExpenseRepository repository,
    ExpenseCommandParser parser = const ExpenseCommandParser(),
    BillNotificationService? notifications,
  })  : _repository = repository,
        _parser = parser,
        _notifications = notifications ?? BillNotificationService.instance,
        super(const ExpenseState()) {
    on<LoadExpenseDataEvent>(_onLoad);
    on<AddExpenseCommandEvent>(_onAddExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<ClearAllExpensesEvent>(_onClearAll);
    on<AddBillEvent>(_onAddBill);
    on<MarkBillPaidEvent>(_onMarkPaid);
    on<DeleteBillEvent>(_onDeleteBill);
    on<ToggleBillEnabledEvent>(_onToggleBill);
    on<RescheduleBillRemindersEvent>(_onRescheduleReminders);
  }

  Future<void> _onLoad(
    LoadExpenseDataEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    try {
      final expenses = await _repository.getAllExpenses();
      final bills = await _repository.getAllBills();
      emit(state.copyWith(
        status: ExpenseStatus.success,
        expenses: expenses,
        bills: bills,
      ));
      await _rescheduleAll(bills);
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: 'Failed to load: $e',
      ));
    }
  }

  Future<void> _onAddExpense(
    AddExpenseCommandEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final result = _parser.parse(event.rawCommand);
    if (!result.isSuccess) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: result.error,
      ));
      return;
    }
        final parsed = result.expense!;
    final entry = ExpenseEntry(
      id: _uuid(),
      amount: parsed.amount,
      category: parsed.category,
      note: parsed.note,
      createdAt: DateTime.now(),
      currency: parsed.currency,
    );
    await _repository.addExpense(entry);
    final updated = [entry, ...state.expenses];
    emit(state.copyWith(
      status: ExpenseStatus.success,
      expenses: updated,
      message: 'Added ${parsed.currency}${parsed.amount.abs().toStringAsFixed(2)} to #${parsed.category}',
    ));
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    await _repository.deleteExpense(event.id);
    final updated = state.expenses.where((e) => e.id != event.id).toList();
    emit(state.copyWith(
      status: ExpenseStatus.success,
      expenses: updated,
    ));
  }

  Future<void> _onClearAll(
    ClearAllExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    await _repository.clearAllExpenses();
    emit(state.copyWith(
      status: ExpenseStatus.success,
      expenses: const [],
      message: 'All expense entries cleared',
    ));
  }

  Future<void> _onAddBill(
    AddBillEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    if (event.dueDayOfMonth < 1 || event.dueDayOfMonth > 31) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: 'Due day must be between 1 and 31',
      ));
      return;
    }
    final now = DateTime.now();
    final nextDue = _nextDueFromDay(now, event.dueDayOfMonth);
    final bill = BillReminder(
      id: _uuid(),
      title: event.title,
      amount: event.amount,
      dueDayOfMonth: event.dueDayOfMonth,
      category: event.category,
      enabled: true,
      lastPaidAt: DateTime.fromMillisecondsSinceEpoch(0),
      nextDueAt: nextDue,
    );
    await _repository.addBill(bill);
    final updated = [...state.bills, bill];
    emit(state.copyWith(
      status: ExpenseStatus.success,
      bills: updated,
      message: 'Bill added: ${event.title}',
    ));
    await _rescheduleAll(updated);
  }

  Future<void> _onMarkPaid(
    MarkBillPaidEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final now = DateTime.now();
    await _repository.markBillPaid(event.id, now);
    final updated = state.bills.map((b) {
      if (b.id == event.id) {
        return b.rollForward(now).copyWith(lastPaidAt: now);
      }
      return b;
    }).toList();
    emit(state.copyWith(
      status: ExpenseStatus.success,
      bills: updated,
      message: 'Bill marked as paid',
    ));
    await _rescheduleAll(updated);
  }

  Future<void> _onDeleteBill(
    DeleteBillEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    await _repository.deleteBill(event.id);
    final updated = state.bills.where((b) => b.id != event.id).toList();
    await _notifications.cancel(event.id.hashCode);
    emit(state.copyWith(
      status: ExpenseStatus.success,
      bills: updated,
    ));
  }

  Future<void> _onToggleBill(
    ToggleBillEnabledEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final updated = <BillReminder>[];
    for (final b in state.bills) {
      if (b.id == event.id) {
        final toggled = b.copyWith(enabled: !b.enabled);
        updated.add(toggled);
        await _repository.updateBill(toggled);
        if (!toggled.enabled) {
          await _notifications.cancel(toggled.id.hashCode);
        }
      } else {
        updated.add(b);
      }
    }
    emit(state.copyWith(
      status: ExpenseStatus.success,
      bills: updated,
    ));
    await _rescheduleAll(updated);
  }

  Future<void> _onRescheduleReminders(
    RescheduleBillRemindersEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    await _rescheduleAll(state.bills);
    emit(state.copyWith(message: 'Reminders rescheduled'));
  }

  Future<void> _rescheduleAll(List<BillReminder> bills) async {
    await _notifications.cancelAll();
    for (final b in bills) {
      if (!b.enabled) continue;
      // Schedule for the morning of the due date (or 1 day before if more
      // than 3 days out — keep it simple and reliable).
      final now = DateTime.now();
      final due = b.daysUntilDue(now) <= 1
          ? DateTime(now.year, now.month, now.day, 9, 0)
          : b.nextDueAt.subtract(const Duration(days: 1)).copyWithX(9, 0);
      await _notifications.scheduleBillReminder(
        id: b.id.hashCode,
        title: 'Bill Due: ${b.title}',
        body: '${b.title} of ${b.amount.toStringAsFixed(2)} is due on '
            '${b.nextDueAt.day}/${b.nextDueAt.month}/${b.nextDueAt.year}.',
        scheduledDate: due,
      );
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────
  DateTime _nextDueFromDay(DateTime now, int day) {
    final candidate = DateTime(now.year, now.month, _clampDay(now.year, now.month, day));
    if (candidate.isBefore(DateTime(now.year, now.month, now.day))) {
      final nextMonth = now.month == 12
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);
      return DateTime(nextMonth.year, nextMonth.month,
          _clampDay(nextMonth.year, nextMonth.month, day));
    }
    return candidate;
  }

  int _clampDay(int year, int month, int day) {
    if (day < 1) return 1;
    final firstNext = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    final lastDay = firstNext.subtract(const Duration(days: 1)).day;
    return day > lastDay ? lastDay : day;
  }

  String _uuid() {
    return '${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(this)}_${state.expenses.length}';
  }
}

/// Extension helper used internally by the bloc for date math.
extension on DateTime {
  DateTime copyWithX(int hour, int minute) {
    return DateTime(year, month, day, hour, minute);
  }
}
