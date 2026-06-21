import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/aizen_theme.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/bill_reminder.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/expense_input_bar.dart';
import '../widgets/expense_ledger_row.dart';
import '../widgets/bill_reminder_row.dart';
import '../widgets/expense_summary_header.dart';
import '../widgets/add_bill_sheet.dart';

class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    context.read<ExpenseBloc>().add(const LoadExpenseDataEvent());
  }

  @override
  void dispose() {
    _tab.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AizenTheme.amoledBlack,
      appBar: AppBar(
        backgroundColor: AizenTheme.amoledBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Expense & Bills'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AizenTheme.primaryPurple,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AizenTheme.primaryPurple,
          unselectedLabelColor: AizenTheme.textTertiary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: 'LEDGER'),
            Tab(text: 'BILLS'),
          ],
        ),
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listenWhen: (p, c) => c.message != null || c.errorMessage != null,
        listener: (ctx, state) {
          final msg = state.message ?? state.errorMessage;
          if (msg == null) return;
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
          );
        },
        child: TabBarView(
          controller: _tab,
          children: [
            _buildLedgerTab(),
            _buildBillsTab(),
          ],
        ),
      ),
    );
  }

  // ── LEDGER TAB ───────────────────────────────────────────────────────
  Widget _buildLedgerTab() {
    return Column(
      children: [
        BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (ctx, state) => ExpenseSummaryHeader(state: state),
        ),
        ExpenseInputBar(
          controller: _inputController,
          onSubmit: (val) {
            if (val.trim().isEmpty) return;
            AizenHaptics.light();
            context.read<ExpenseBloc>().add(AddExpenseCommandEvent(val));
            _inputController.clear();
          },
        ),
        Expanded(
          child: BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (ctx, state) {
              if (state.expenses.isEmpty) {
                return _emptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No entries yet',
                  hint: 'Type `50 #lunch` above to add your first expense',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: state.expenses.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AizenTheme.hairlineBorder,
                ),
                itemBuilder: (ctx, i) {
                  final e = state.expenses[i];
                  return ExpenseLedgerRow(
                    entry: e,
                    onDelete: () {
                      AizenHaptics.light();
                      context.read<ExpenseBloc>().add(DeleteExpenseEvent(e.id));
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── BILLS TAB ────────────────────────────────────────────────────────
  Widget _buildBillsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Text(
                'BILL PAY REMINDERS',
                style: TextStyle(
                  color: AizenTheme.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _showAddBillSheet,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Bill'),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (ctx, state) {
              if (state.bills.isEmpty) {
                return _emptyState(
                  icon: Icons.event_note_outlined,
                  title: 'No bills tracked',
                  hint: 'Add your rent, internet, utilities — get persistent reminders',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: state.bills.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AizenTheme.hairlineBorder,
                ),
                itemBuilder: (ctx, i) {
                  final b = state.bills[i];
                  return BillReminderRow(
                    bill: b,
                    onMarkPaid: () {
                      AizenHaptics.medium();
                      context.read<ExpenseBloc>().add(MarkBillPaidEvent(b.id));
                    },
                    onToggle: () {
                      AizenHaptics.light();
                      context
                          .read<ExpenseBloc>()
                          .add(ToggleBillEnabledEvent(b.id));
                    },
                    onDelete: () {
                      AizenHaptics.light();
                      context.read<ExpenseBloc>().add(DeleteBillEvent(b.id));
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String hint,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AizenTheme.textTertiary, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AizenTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AizenTheme.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBillSheet() {
    AizenHaptics.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AddBillSheet(
        onSubmit: (title, amount, day, category) {
          context.read<ExpenseBloc>().add(AddBillEvent(
                title: title,
                amount: amount,
                dueDayOfMonth: day,
                category: category,
              ));
        },
      ),
    );
  }
}
