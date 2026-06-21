import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/aizen_theme.dart';

class ExpenseInputBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  const ExpenseInputBar({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  State<ExpenseInputBar> createState() => _ExpenseInputBarState();
}

class _ExpenseInputBarState extends State<ExpenseInputBar> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text.trim();
    final canSubmit = text.isNotEmpty && _looksValid(text);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AizenTheme.surfaceMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AizenTheme.hairlineBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AizenTheme.primaryPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '\u{09F3}',
              style: TextStyle(
                color: AizenTheme.primaryPurple,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              style: const TextStyle(
                color: AizenTheme.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: '50 #lunch  •  1200 #internet  •  -20 #refund',
                hintStyle: TextStyle(color: AizenTheme.textTertiary, fontSize: 12),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (val) {
                if (canSubmit) {
                  widget.onSubmit(val);
                  _focus.requestFocus();
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: canSubmit
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onSubmit(widget.controller.text);
                  }
                : null,
            icon: const Icon(Icons.arrow_circle_up_rounded, size: 28),
            color: canSubmit
                ? AizenTheme.primaryPurple
                : AizenTheme.textTertiary,
          ),
        ],
      ),
    );
  }

  bool _looksValid(String s) {
    return RegExp(r'^[+-]?\d+(?:\.\d+)?(\s*#[A-Za-z0-9_\-]+)?(\s+.*)?$')
        .hasMatch(s);
  }
}
