import 'dart:async';
import '../entities/expense_entry.dart';
import '../entities/bill_reminder.dart';

/// Contract for the local expense ledger repository.
abstract class ExpenseRepository {
  // Expense entries
  Future<List<ExpenseEntry>> getAllExpenses();
  Future<void> addExpense(ExpenseEntry entry);
  Future<void> deleteExpense(String id);
  Future<void> clearAllExpenses();

  // Bill reminders
  Future<List<BillReminder>> getAllBills();
  Future<void> addBill(BillReminder bill);
  Future<void> updateBill(BillReminder bill);
  Future<void> deleteBill(String id);
  Future<void> markBillPaid(String id, DateTime paidAt);
}
