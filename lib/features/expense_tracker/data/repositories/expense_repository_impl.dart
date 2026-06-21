import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/bill_reminder.dart';
import '../../domain/repositories/expense_repository.dart';

/// SharedPreferences-backed implementation of [ExpenseRepository].
///
/// All entries are stored as a single JSON-encoded list under one key.
/// This is intentionally simple and RAM-friendly — even 10,000 ledger
/// entries serialise to well under 1MB, and JSON decoding is far cheaper
/// than running a full embedded DB.
class ExpenseLocalDataSource {
  static const _expenseKey = 'aizen_expense_entries_v1';
  static const _billKey = 'aizen_expense_bills_v1';

  final SharedPreferences _prefs;
  ExpenseLocalDataSource(this._prefs);

  List<ExpenseEntry> loadExpenses() {
    final raw = _prefs.getString(_expenseKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ExpenseEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveExpenses(List<ExpenseEntry> entries) async {
    final list = entries.map((e) => e.toJson()).toList();
    await _prefs.setString(_expenseKey, jsonEncode(list));
  }

  List<BillReminder> loadBills() {
    final raw = _prefs.getString(_billKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => BillReminder.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBills(List<BillReminder> bills) async {
    final list = bills.map((b) => b.toJson()).toList();
    await _prefs.setString(_billKey, jsonEncode(list));
  }
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _ds;
  ExpenseRepositoryImpl(this._ds);

  @override
  Future<List<ExpenseEntry>> getAllExpenses() async {
    return _ds.loadExpenses();
  }

  @override
  Future<void> addExpense(ExpenseEntry entry) async {
    final list = _ds.loadExpenses();
    list.insert(0, entry);
    // Cap at 1000 entries to protect storage on low-RAM devices.
    if (list.length > 1000) list.removeRange(1000, list.length);
    await _ds.saveExpenses(list);
  }

  @override
  Future<void> deleteExpense(String id) async {
    final list = _ds.loadExpenses().where((e) => e.id != id).toList();
    await _ds.saveExpenses(list);
  }

  @override
  Future<void> clearAllExpenses() async {
    await _ds.saveExpenses([]);
  }

  @override
  Future<List<BillReminder>> getAllBills() async {
    return _ds.loadBills();
  }

  @override
  Future<void> addBill(BillReminder bill) async {
    final list = _ds.loadBills();
    list.add(bill);
    await _ds.saveBills(list);
  }

  @override
  Future<void> updateBill(BillReminder bill) async {
    final list = _ds.loadBills().map((b) => b.id == bill.id ? bill : b).toList();
    await _ds.saveBills(list);
  }

  @override
  Future<void> deleteBill(String id) async {
    final list = _ds.loadBills().where((b) => b.id != id).toList();
    await _ds.saveBills(list);
  }

  @override
  Future<void> markBillPaid(String id, DateTime paidAt) async {
    final list = _ds.loadBills();
    for (var i = 0; i < list.length; i++) {
      if (list[i].id == id) {
        final rolled = list[i].rollForward(paidAt).copyWith(
          lastPaidAt: paidAt,
        );
        list[i] = rolled;
        break;
      }
    }
    await _ds.saveBills(list);
  }
}
