import 'package:flutter/material.dart';
import '../../../../core/theme/aizen_theme.dart';
import '../../../calculator/presentation/widgets/mini_calculator_overlay.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/services/expense_command_parser.dart';

class ExpenseInputBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final List<ExpenseEntry> expenses;

  const ExpenseInputBar({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.expenses,
  });

  @override
  State<ExpenseInputBar> createState() => _ExpenseInputBarState();
}

class _ExpenseInputBarState extends State<ExpenseInputBar> {
  late final FocusNode _focus;
  final _parser = const ExpenseCommandParser();

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text.trim();
    final canSubmit = text.isNotEmpty && _looksValid(text);

    // Dynamic micro-preview logic
    ParsedExpense? parsedPreview;
    double pctIncrease = 0.0;
    double pctOfTotal = 0.0;
    bool isNewCategory = true;

    if (canSubmit) {
      final res = _parser.parse(text);
      if (res.isSuccess) {
        parsedPreview = res.expense;
        if (parsedPreview != null && parsedPreview.amount > 0) {
          final amt = parsedPreview.amount;
          final cat = parsedPreview.category;
          
          final currentCatSum = widget.expenses
              .where((e) => e.category == cat && e.amount > 0)
              .fold(0.0, (sum, e) => sum + e.amount);
              
          final totalSum = widget.expenses
              .where((e) => e.amount > 0)
              .fold(0.0, (sum, e) => sum + e.amount);
              
          isNewCategory = currentCatSum == 0;
          pctIncrease = currentCatSum > 0 ? (amt / currentCatSum) * 100 : 100.0;
          pctOfTotal = totalSum > 0 ? (amt / totalSum) * 100 : 100.0;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AizenTheme.surfaceMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AizenTheme.hairlineBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Interactive CALC overlay button
              GestureDetector(
                onTap: () async {
                  AizenHaptics.selection();
                  final result = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => MiniCalculatorOverlay(
                      initialExpression: widget.controller.text,
                    ),
                  );
                  if (result != null && result.isNotEmpty) {
                    final currText = widget.controller.text.trim();
                    final tagMatch = RegExp(r'#\S+.*').firstMatch(currText);
                    if (tagMatch != null) {
                      widget.controller.text = '$result ${tagMatch.group(0)}';
                    } else {
                      widget.controller.text = result;
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AizenTheme.primaryPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AizenTheme.primaryPurple.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calculate_outlined, color: AizenTheme.primaryPurple, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'CALC',
                        style: TextStyle(
                          color: AizenTheme.primaryPurple,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
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
                    hintText: '\$50 #lunch  •  ৳1200 #internet  •  -€20 #refund',
                    hintStyle: TextStyle(color: AizenTheme.textTertiary, fontSize: 11),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
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
                        AizenHaptics.light();
                        widget.onSubmit(widget.controller.text);
                      }
                    : null,
                icon: const Icon(Icons.arrow_circle_up_rounded, size: 28),
                color: canSubmit
                    ? AizenTheme.primaryPurple
                    : AizenTheme.textTertiary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          // Micro-Preview Card for calculated category percentage change
          if (parsedPreview != null && parsedPreview.amount > 0) ...[
            const SizedBox(height: 6),
            const Divider(height: 1, color: AizenTheme.hairlineBorder),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded, size: 12, color: AizenTheme.accentCyan),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isNewCategory
                        ? 'New category #${parsedPreview.category} • represents ${pctOfTotal.toStringAsFixed(1)}% of total spent'
                        : 'Adds ${parsedPreview.currency}${parsedPreview.amount.toStringAsFixed(2)} • increases #${parsedPreview.category} sum by +${pctIncrease.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: AizenTheme.accentCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _looksValid(String s) {
    return RegExp(r'^([\$৳£€¥]?)\s*([+-]?)\s*([\$৳£€¥]?)\s*\d+(?:\.\d+)?(\s*#[A-Za-z0-9_\-]+)?(\s+.*)?$')
        .hasMatch(s);
  }
}
