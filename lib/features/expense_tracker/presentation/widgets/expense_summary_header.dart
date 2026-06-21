import 'package:flutter/material.dart';
import '../../../../core/theme/aizen_theme.dart';
import '../bloc/expense_state.dart';

class ExpenseSummaryHeader extends StatelessWidget {
  final ExpenseState state;
  const ExpenseSummaryHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AizenTheme.surfaceMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AizenTheme.hairlineBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'TODAY',
                style: TextStyle(
                  color: AizenTheme.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              const Text(
                'THIS MONTH',
                style: TextStyle(
                  color: AizenTheme.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _format(state.todaySpend),
                style: TextStyle(
                  color: state.todaySpend < 0
                      ? AizenTheme.accentGreen
                      : AizenTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const Spacer(),
              Text(
                _format(state.monthSpend),
                style: TextStyle(
                  color: state.monthSpend < 0
                      ? AizenTheme.accentGreen
                      : AizenTheme.primaryPurple,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AizenTheme.hairlineBorder),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.event_available,
                  size: 14, color: AizenTheme.accentAmber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _billsLine(state),
                  style: const TextStyle(
                    color: AizenTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(double v) {
    final sign = v < 0 ? '+' : ''; // refunds are positive for the wallet
    return '$sign\u{09F3}${v.abs().toStringAsFixed(2)}';
  }

  String _billsLine(ExpenseState s) {
    final upcoming = s.billsDueWithin(7);
    if (upcoming.isEmpty) return 'No bills due in the next 7 days';
    if (upcoming.length == 1) {
      final b = upcoming.first;
      final d = b.daysUntilDue(DateTime.now());
      return 'Due soon: ${b.title} (\u{09F3}${b.amount.toStringAsFixed(0)}) — $d day${d == 1 ? '' : 's'}';
    }
    return '${upcoming.length} bills due in the next 7 days';
  }
}
