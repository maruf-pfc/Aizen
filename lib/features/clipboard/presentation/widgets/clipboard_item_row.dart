import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/aizen_theme.dart';
import '../../domain/entities/clipboard_item.dart';

class ClipboardItemRow extends StatelessWidget {
  final ClipboardItem item;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const ClipboardItemRow({
    super.key,
    required this.item,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _kindColor(item.kind);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kind badge
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _kindLabel(item.kind).toUpperCase(),
                            style: TextStyle(
                              color: accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _timeLabel(item.copiedAt),
                          style: const TextStyle(
                            color: AizenTheme.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                        if (item.pinned) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.push_pin,
                              size: 11, color: AizenTheme.accentAmber),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AizenTheme.textPrimary,
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Action icons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBtn(
                    icon: item.pinned
                        ? Icons.push_pin
                        : Icons.push_pin_outlined,
                    color: item.pinned
                        ? AizenTheme.accentAmber
                        : AizenTheme.textTertiary,
                    onTap: onTogglePin,
                  ),
                  _iconBtn(
                    icon: Icons.copy_outlined,
                    color: AizenTheme.accentCyan,
                    onTap: onTap,
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
        ),
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Color _kindColor(ClipboardKind k) {
    switch (k) {
      case ClipboardKind.link:
        return AizenTheme.accentCyan;
      case ClipboardKind.snippet:
        return AizenTheme.accentAmber;
      case ClipboardKind.plain:
        return AizenTheme.accentGreen;
    }
  }

  String _kindLabel(ClipboardKind k) {
    switch (k) {
      case ClipboardKind.link:
        return 'Link';
      case ClipboardKind.snippet:
        return 'Snippet';
      case ClipboardKind.plain:
        return 'Plain';
    }
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
