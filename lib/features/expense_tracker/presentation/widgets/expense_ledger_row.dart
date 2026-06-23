import 'package:flutter/material.dart';
import '../../../../core/theme/aizen_theme.dart';
import '../../domain/entities/expense_entry.dart';

class ExpenseLedgerRow extends StatelessWidget {
  final ExpenseEntry entry;
  final VoidCallback onDelete;

  const ExpenseLedgerRow({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.amount < 0;
    final amountColor =
        isIncome ? AizenTheme.accentGreen : AizenTheme.textPrimary;
    final sign = isIncome ? '+' : '-';

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AizenTheme.accentRed.withValues(alpha: 0.15),
        child: const Icon(Icons.delete_outline,
            color: AizenTheme.accentRed, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                color: isIncome
                    ? AizenTheme.accentGreen
                    : AizenTheme.primaryPurple,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AizenTheme.primaryPurple
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${entry.category}',
                          style: const TextStyle(
                            color: AizenTheme.primaryPurple,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeLabel(entry.createdAt),
                        style: const TextStyle(
                          color: AizenTheme.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  if (entry.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AizenTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$sign${entry.currency}${entry.amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: amountColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day}/${t.month}';
  }
}
