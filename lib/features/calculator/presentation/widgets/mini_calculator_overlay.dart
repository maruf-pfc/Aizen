import 'package:flutter/material.dart';
import '../../../../core/theme/aizen_theme.dart';
import '../../domain/engine/calculator_engine.dart';

class MiniCalculatorOverlay extends StatefulWidget {
  final String initialExpression;

  const MiniCalculatorOverlay({
    super.key,
    this.initialExpression = '',
  });

  @override
  State<MiniCalculatorOverlay> createState() => _MiniCalculatorOverlayState();
}

class _MiniCalculatorOverlayState extends State<MiniCalculatorOverlay> {
  final _engine = const CalculatorEngine();
  String _expression = '';
  String _preview = '0';
  String? _error;
  static double _memory = 0;
  bool _isDeg = true;

  @override
  void initState() {
    super.initState();
    _expression = _sanitizeInitial(widget.initialExpression);
    _recomputePreview();
  }

  String _sanitizeInitial(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9\.\+\-\*\/\(\)\%\s]'), '').trim();
    return cleaned;
  }

  void _append(String token) {
    AizenHaptics.selection();
    setState(() {
      _error = null;
      _expression += token;
      _recomputePreview();
    });
  }

  void _backspace() {
    AizenHaptics.light();
    setState(() {
      _error = null;
      if (_expression.isEmpty) return;
      final lastChar = _expression[_expression.length - 1];
      if (RegExp(r'[a-zA-Z]').hasMatch(lastChar)) {
        var i = _expression.length - 1;
        while (i > 0 && RegExp(r'[a-zA-Z]').hasMatch(_expression[i - 1])) {
          i--;
        }
        _expression = _expression.substring(0, i);
      } else {
        _expression = _expression.substring(0, _expression.length - 1);
      }
      _recomputePreview();
    });
  }

  void _clear() {
    AizenHaptics.medium();
    setState(() {
      _expression = '';
      _preview = '0';
      _error = null;
    });
  }

  void _recomputePreview() {
    if (_expression.trim().isEmpty) {
      _preview = '0';
      _error = null;
      return;
    }
    final result = _engine.evaluate(_expression, degMode: _isDeg);
    if (result.isSuccess) {
      _preview = result.formatted;
      _error = null;
    } else {
      _preview = '…';
      _error = null;
    }
  }

  void _evaluateAndSubmit() {
    if (_expression.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    AizenHaptics.medium();
    final result = _engine.evaluate(_expression, degMode: _isDeg);
    if (result.isSuccess) {
      Navigator.pop(context, result.formatted);
    } else {
      setState(() {
        _error = result.error;
        _preview = 'Error';
      });
      AizenHaptics.medium();
    }
  }

  void _memoryOp(String op) {
    AizenHaptics.selection();
    setState(() {
      switch (op) {
        case 'MC':
          _memory = 0;
          break;
        case 'MR':
          _expression += CalculatorResult.format(_memory);
          _recomputePreview();
          break;
        case 'M+':
          final r = _engine.evaluate(_expression, degMode: _isDeg);
          if (r.isSuccess) _memory += r.value;
          break;
        case 'M-':
          final r = _engine.evaluate(_expression, degMode: _isDeg);
          if (r.isSuccess) _memory -= r.value;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AizenTheme.surfaceLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AizenTheme.shapeLg)),
      ),
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AizenTheme.hairlineBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MINI CALCULATOR',
                style: TextStyle(
                  color: AizenTheme.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: () {
                  AizenHaptics.light();
                  setState(() {
                    _isDeg = !_isDeg;
                    _recomputePreview();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _isDeg
                        ? AizenTheme.primaryPurple.withValues(alpha: 0.12)
                        : AizenTheme.accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _isDeg
                          ? AizenTheme.primaryPurple.withValues(alpha: 0.4)
                          : AizenTheme.accentGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _isDeg ? 'DEG' : 'RAD',
                    style: TextStyle(
                      color: _isDeg ? AizenTheme.primaryPurple : AizenTheme.accentGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AizenTheme.surfaceMid,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AizenTheme.hairlineBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _expression.isEmpty ? ' ' : _expression,
                  style: const TextStyle(
                    color: AizenTheme.textSecondary,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _preview,
                  style: TextStyle(
                    color: _error != null ? AizenTheme.accentRed : AizenTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AizenTheme.accentRed,
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildKeypadRow(['MC', 'MR', 'M+', 'M-']),
          _buildKeypadRow(['sin(', 'cos(', 'tan(', 'sqrt(']),
          _buildKeypadRow(['7', '8', '9', '/']),
          _buildKeypadRow(['4', '5', '6', '*']),
          _buildKeypadRow(['1', '2', '3', '-']),
          _buildKeypadRow(['C', '0', '.', '+']),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _backspace,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AizenTheme.accentAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AizenTheme.accentAmber.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.backspace_outlined, color: AizenTheme.accentAmber, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: _evaluateAndSubmit,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AizenTheme.primaryPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'APPLY',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: keys.map((key) {
          final isOperator = ['/', '*', '-', '+'].contains(key);
          final isMemory = ['MC', 'MR', 'M+', 'M-'].contains(key);
          final isTrig = ['sin(', 'cos(', 'tan(', 'sqrt('].contains(key);
          final isClear = key == 'C';
          
          Color textColor = AizenTheme.textPrimary;
          Color bgColor = AizenTheme.surfaceMid;
          if (isOperator) {
            textColor = AizenTheme.primaryPurple;
            bgColor = AizenTheme.surfaceHigh;
          } else if (isMemory) {
            textColor = AizenTheme.accentAmber;
            bgColor = AizenTheme.surfaceHigh;
          } else if (isTrig) {
            textColor = AizenTheme.accentCyan;
            bgColor = AizenTheme.surfaceHigh;
          } else if (isClear) {
            textColor = AizenTheme.accentRed;
            bgColor = AizenTheme.accentRed.withValues(alpha: 0.15);
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Material(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    if (isClear) {
                      _clear();
                    } else if (isMemory) {
                      _memoryOp(key);
                    } else {
                      _append(key);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    child: Text(
                      key.endsWith('(') ? key.substring(0, key.length - 1) : key,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
