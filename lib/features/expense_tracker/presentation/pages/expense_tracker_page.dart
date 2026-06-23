import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/aizen_theme.dart';
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
    _tab = TabController(length: 3, vsync: this);
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
          onPressed: () {
            AizenHaptics.light();
            Navigator.pop(context);
          },
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
            Tab(text: 'ANALYTICS'),
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
            _buildAnalyticsTab(),
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
        BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (ctx, state) => ExpenseInputBar(
            controller: _inputController,
            expenses: state.expenses,
            onSubmit: (val) {
              if (val.trim().isEmpty) return;
              AizenHaptics.light();
              context.read<ExpenseBloc>().add(AddExpenseCommandEvent(val));
              _inputController.clear();
            },
          ),
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

  // ── ANALYTICS TAB ────────────────────────────────────────────────────
  Widget _buildAnalyticsTab() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (ctx, state) {
        final expenses = state.expenses;
        
        final totalSpending = expenses
            .where((e) => e.amount > 0)
            .fold(0.0, (sum, e) => sum + e.amount);
            
        final totalRefunds = expenses
            .where((e) => e.amount < 0)
            .fold(0.0, (sum, e) => sum + e.amount.abs());
            
        final netBalance = totalRefunds - totalSpending;
        
        final uniqueDays = expenses
            .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
            .toSet()
            .length;
            
        final avgSpend = totalSpending / (uniqueDays > 0 ? uniqueDays : 1);

        // Group expenses by category
        final categorySpends = <String, double>{};
        for (final e in expenses) {
          if (e.amount > 0) {
            categorySpends[e.category] = (categorySpends[e.category] ?? 0.0) + e.amount;
          }
        }
        
        final sortedCategories = categorySpends.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                _buildMetricCard(
                  label: 'REFUNDS/INCOME',
                  value: '\u{09F3}${totalRefunds.toStringAsFixed(2)}',
                  icon: Icons.south_west_rounded,
                  color: AizenTheme.accentGreen,
                ),
                const SizedBox(width: 10),
                _buildMetricCard(
                  label: 'TOTAL EXPENSES',
                  value: '\u{09F3}${totalSpending.toStringAsFixed(2)}',
                  icon: Icons.north_east_rounded,
                  color: AizenTheme.accentRed,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildMetricCard(
                  label: 'NET BALANCE',
                  value: '${netBalance >= 0 ? '+' : ''}\u{09F3}${netBalance.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: netBalance >= 0 ? AizenTheme.accentGreen : AizenTheme.primaryPurple,
                ),
                const SizedBox(width: 10),
                _buildMetricCard(
                  label: 'DAILY AVG',
                  value: '\u{09F3}${avgSpend.toStringAsFixed(2)}',
                  icon: Icons.analytics_outlined,
                  color: AizenTheme.accentCyan,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Section Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'CATEGORY SPENDING BREAKDOWN',
                style: TextStyle(
                  color: AizenTheme.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            
            if (sortedCategories.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AizenTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AizenTheme.hairlineBorder),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.pie_chart_outline, color: AizenTheme.textTertiary, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'No category spending data yet',
                      style: TextStyle(color: AizenTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add expenses in the Ledger tab to populate analytics',
                      style: TextStyle(color: AizenTheme.textTertiary, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AizenTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AizenTheme.hairlineBorder),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedCategories.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AizenTheme.hairlineBorder),
                  itemBuilder: (ctx, idx) {
                    final entry = sortedCategories[idx];
                    final pct = totalSpending > 0 ? entry.value / totalSpending : 0.0;
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AizenTheme.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AizenTheme.primaryPurple.withValues(alpha: 0.2)),
                        ),
                        child: const Center(
                          child: Text(
                            '#',
                            style: TextStyle(
                              color: AizenTheme.primaryPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        '#${entry.key.toUpperCase()}',
                        style: const TextStyle(
                          color: AizenTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: AizenTheme.surfaceMid,
                            color: AizenTheme.primaryPurple,
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\u{09F3}${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AizenTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${(pct * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AizenTheme.textTertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AizenTheme.surfaceLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AizenTheme.hairlineBorder, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AizenTheme.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AizenTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
