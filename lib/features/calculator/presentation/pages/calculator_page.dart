import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/engine/calculator_engine.dart';
import 'package:Aizen/core/theme/aizen_theme.dart';
import '../../../navigation_hub/presentation/widgets/navigation_hub_drawer.dart';

/// Aizen v1.6.0 — Scientific Calculator page.
///
/// Dense, space-efficient M3 grid. Supports:
///   • Direct algebraic entry (no equals-chaining surprises)
///   • DEG trig mode toggle
///   • Live preview evaluation as the user types
///   • Memory keys: M+, M-, MR, MC
///   • History tape (last 12 results) — kept in-memory only, no I/O
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _engine = const CalculatorEngine();

  String _expression = '';
  String _preview = '0';
  String? _error;
  double _memory = 0;
  bool _isDeg = true;

  final List<String> _history = [];

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
      // Delete one full token: identifier or single char
      final lastChar = _expression[_expression.length - 1];
      if (RegExp(r'[a-zA-Z]').hasMatch(lastChar)) {
        // Remove the trailing identifier run
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

  void _clearAll() {
    AizenHaptics.medium();
    setState(() {
      _expression = '';
      _preview = '0';
      _error = null;
      _memory = 0;
      _history.clear();
    });
  }

  void _evaluate() {
    if (_expression.trim().isEmpty) return;
    AizenHaptics.medium();
    final result = _engine.evaluate(_expression);
    setState(() {
      if (result.isSuccess) {
        final formatted = result.formatted;
        _history.insert(0, '$_expression = $formatted');
        if (_history.length > 12) _history.removeLast();
        _expression = formatted;
        _preview = formatted;
        _error = null;
      } else {
        _error = result.error;
        _preview = 'Error';
      }
    });
  }

  void _recomputePreview() {
    if (_expression.trim().isEmpty) {
      _preview = '0';
      _error = null;
      return;
    }
    final result = _engine.evaluate(_expression);
    if (result.isSuccess) {
      _preview = result.formatted;
      _error = null;
    } else {
      _preview = '…';
      _error = null; // don't show errors during typing, only on evaluate
    }
  }

  void _toggleDeg() {
    AizenHaptics.light();
    setState(() => _isDeg = !_isDeg);
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
          final r = _engine.evaluate(_expression);
          if (r.isSuccess) _memory += r.value;
          break;
        case 'M-':
          final r = _engine.evaluate(_expression);
          if (r.isSuccess) _memory -= r.value;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: AizenTheme.amoledBlack,
      drawer: canPop ? null : const NavigationHubDrawer(),
      appBar: AppBar(
        backgroundColor: AizenTheme.amoledBlack,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
        title: const Text('Calculator'),
        actions: [
          _DegRadToggle(isDeg: _isDeg, onToggle: _toggleDeg),
          IconButton(
            icon: const Icon(Icons.history, size: 20),
            onPressed: _showHistory,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, size: 20),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Display panel ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: AizenTheme.surfaceLow,
                border: Border(
                  bottom: BorderSide(color: AizenTheme.hairlineBorder),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Memory indicator row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_memory != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AizenTheme.accentAmber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AizenTheme.accentAmber.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            'M ${CalculatorResult.format(_memory)}',
                            style: const TextStyle(
                              color: AizenTheme.accentAmber,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Text(
                        _isDeg ? 'DEG' : 'RAD',
                        style: const TextStyle(
                          color: AizenTheme.textTertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Expression line
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 60),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expression.isEmpty ? ' ' : _expression,
                        style: TextStyle(
                          color: AizenTheme.textSecondary,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Preview / result line
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 64),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _preview,
                        style: TextStyle(
                          color: _error != null
                              ? AizenTheme.accentRed
                              : AizenTheme.textPrimary,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AizenTheme.accentRed,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // ── Scientific row ───────────────────────────────────────
            _buildScientificRow(),
            // ── Keypad ───────────────────────────────────────────────
            Expanded(
              child: _buildKeypad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScientificRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: AizenTheme.surfaceLow,
        border: Border(
          bottom: BorderSide(color: AizenTheme.hairlineBorder),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _sciKey('sin(', AizenTheme.primaryPurple),
            _sciKey('cos(', AizenTheme.primaryPurple),
            _sciKey('tan(', AizenTheme.primaryPurple),
            _sciKey('asin(', AizenTheme.primaryPurple),
            _sciKey('acos(', AizenTheme.primaryPurple),
            _sciKey('atan(', AizenTheme.primaryPurple),
            _sciKey('log(', AizenTheme.accentCyan),
            _sciKey('ln(', AizenTheme.accentCyan),
            _sciKey('exp(', AizenTheme.accentCyan),
            _sciKey('sqrt(', AizenTheme.accentCyan),
            _sciKey('cbrt(', AizenTheme.accentCyan),
            _sciKey('abs(', AizenTheme.accentCyan),
            _sciKey('pi', AizenTheme.accentGreen),
            _sciKey('e', AizenTheme.accentGreen),
            _sciKey('^', AizenTheme.accentAmber),
            _sciKey('(', AizenTheme.accentAmber),
            _sciKey(')', AizenTheme.accentAmber),
            _sciKey('!', AizenTheme.accentAmber),
          ],
        ),
      ),
    );
  }

  Widget _sciKey(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: AizenTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (label == '!') {
              _append('!'); // not in engine; ignored
            } else {
              _append(label);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      color: AizenTheme.amoledBlack,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Memory row
          Row(
            children: [
              _memKey('MC'),
              _memKey('MR'),
              _memKey('M+'),
              _memKey('M-'),
            ],
          ),
          const SizedBox(height: 6),
          // Numeric + operators
 Expanded(
            child: Column(
              children: [
                Expanded(child: Row(
                  children: [
                    _numKey('7'),
                    _numKey('8'),
                    _numKey('9'),
                    _opKey('÷', '/'),
                  ],
                )),
                Expanded(child: Row(
                  children: [
                    _numKey('4'),
                    _numKey('5'),
                    _numKey('6'),
                    _opKey('×', '*'),
                  ],
                )),
                Expanded(child: Row(
                  children: [
                    _numKey('1'),
                    _numKey('2'),
                    _numKey('3'),
                    _opKey('−', '-'),
                  ],
                )),
                Expanded(child: Row(
                  children: [
                    _numKey('.'),
                    _numKey('0'),
                    _numKey('%', altLabel: 'mod'),
                    _opKey('+', '+'),
                  ],
                )),
                Expanded(child: Row(
                  children: [
                    _specialKey(
                      label: 'AC',
                      color: AizenTheme.accentRed,
                      onTap: _clear,
                      flex: 1,
                    ),
                    _specialKey(
                      label: '⌫',
                      color: AizenTheme.accentAmber,
                      onTap: _backspace,
                      flex: 1,
                    ),
                    _specialKey(
                      label: '=',
                      color: AizenTheme.primaryPurple,
                      onTap: _evaluate,
                      flex: 2,
                      isPrimary: true,
                    ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _memKey(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: AizenTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _memoryOp(label),
            child: Container(
              height: 38,
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  color: AizenTheme.accentAmber,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numKey(String label, {String? altLabel}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: AizenTheme.surfaceMid,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _append(label),
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AizenTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (altLabel != null)
                    Text(
                      altLabel,
                      style: const TextStyle(
                        color: AizenTheme.textTertiary,
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _opKey(String display, String append) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: AizenTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _append(append),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                display,
                style: const TextStyle(
                  color: AizenTheme.primaryPurple,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _specialKey({
    required String label,
    required Color color,
    required VoidCallback onTap,
    int flex = 1,
    bool isPrimary = false,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: isPrimary ? color : color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.black : color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHistory() {
    AizenHaptics.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'History',
                        style: TextStyle(
                          color: AizenTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (_history.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _history.clear();
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: _history.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text(
                              'No calculations yet',
                              style: TextStyle(
                                color: AizenTheme.textTertiary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _history.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: AizenTheme.hairlineBorder,
                          ),
                          itemBuilder: (ctx, i) {
                            final entry = _history[i];
                            final eqIdx = entry.lastIndexOf(' = ');
                            final expr = eqIdx > 0 ? entry.substring(0, eqIdx) : entry;
                            final res = eqIdx > 0
                                ? entry.substring(eqIdx + 3)
                                : '';
                            return ListTile(
                              title: Text(
                                expr,
                                style: const TextStyle(
                                  color: AizenTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                res,
                                style: const TextStyle(
                                  color: AizenTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _expression = res;
                                  _preview = res;
                                  _recomputePreview();
                                });
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DegRadToggle extends StatelessWidget {
  final bool isDeg;
  final VoidCallback onToggle;
  const _DegRadToggle({required this.isDeg, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: AizenTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDeg ? 'DEG' : 'RAD',
                  style: const TextStyle(
                    color: AizenTheme.primaryPurple,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
