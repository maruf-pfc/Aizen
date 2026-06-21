import 'package:flutter/material.dart';
import '../../../../core/theme/aizen_theme.dart';
import '../../domain/entities/bill_reminder.dart';

class BillReminderRow extends StatelessWidget {
  final BillReminder bill;
  final VoidCallback onMarkPaid;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const BillReminderRow({
    super.key,
    required this.bill,
    required this.onMarkPaid,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = bill.daysUntilDue(now);
    final isOverdue = days < 0;
    final isImminent = days >= 0 && days <= 2;

    final accent = isOverdue
        ? AizenTheme.accentRed
        : isImminent
            ? AizenTheme.accentAmber
            : AizenTheme.accentCyan;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Due-day circular indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  bill.nextDueAt.day.toString(),
                  style: TextStyle(
                    color: accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _monthShort(bill.nextDueAt.month),
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Title + meta
          Expanded(
            child: Opacity(
              opacity: bill.enabled ? 1.0 : 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AizenTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AizenTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${bill.category}',
                          style: const TextStyle(
                            color: AizenTheme.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _dueLabel(days),
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Amount + actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u{09F3}${bill.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AizenTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBtn(
                    icon: Icons.check_circle_outline,
                    color: AizenTheme.accentGreen,
                    onTap: onMarkPaid,
                  ),
                  _iconBtn(
                    icon: bill.enabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: bill.enabled
                        ? AizenTheme.accentAmber
                        : AizenTheme.textTertiary,
                    onTap: onToggle,
                  ),
                  _iconBtn(
                    icon: Icons.delete_outline,
                    color: AizenTheme.accentRed,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  String _dueLabel(int days) {
    if (days < 0) return 'OVERDUE';
    if (days == 0) return 'DUE TODAY';
    if (days == 1) return 'DUE TOMORROW';
    return 'IN $days DAYS';
  }

  String _monthShort(int m) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    if (m < 1 || m > 12) return '';
    return months[m - 1];
  }
}
