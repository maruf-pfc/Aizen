// Aizen v1.5.0 — Scientific Calculator Engine.
//
// Pure-Dart, memory-efficient recursive-descent parser supporting:
//   • +, -, *, /, %, ^ (power)
//   • Parentheses (nested arbitrarily deep)
//   • Unary minus / unary plus
//   • Functions: sin, cos, tan, asin, acos, atan, sinh, cosh, tanh
//   • log (base-10), ln (natural), exp, sqrt, cbrt, abs
//   • Constants: pi, e, phi, tau
//   • Implicit multiplication: 2(3+1) == 2*(3+1), 2sin(pi) == 2*sin(pi)
//
// Designed for low-RAM phones: single-pass tokenizer, no regex,
// minimal object allocations per token advance.
import 'dart:math' as math;

/// Result wrapper from the calculator engine.
class CalculatorResult {
  final double value;
  final String? error;
  final String? prettyExpression;

  const CalculatorResult._({
    required this.value,
    this.error,
    this.prettyExpression,
  });

  bool get isSuccess => error == null;

  factory CalculatorResult.success(double value, [String? pretty]) {
    return CalculatorResult._(value: value, prettyExpression: pretty);
  }

  factory CalculatorResult.failure(String message) {
    return CalculatorResult._(value: double.nan, error: message);
  }

  /// Renders the value using Aizen's display rules (no trailing zeros,
  /// no scientific notation for moderate magnitudes).
  String get formatted {
    if (error != null) return 'Error';
    return format(value);
  }

  /// Static format helper usable without a result instance.
  static String format(double v) {
    if (v.isNaN) return 'Error';
    if (v.isInfinite) return v.isNegative ? '-∞' : '∞';
    if (v == v.truncateToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    final s = v.toStringAsFixed(10);
    var trimmed = s;
    if (trimmed.contains('.')) {
      trimmed = trimmed.replaceFirst(RegExp(r'0+$'), '');
      if (trimmed.endsWith('.')) {
        trimmed = trimmed.substring(0, trimmed.length - 1);
      }
    }
    return trimmed;
  }

  @override
  String toString() {
    if (error != null) return 'Calc Error: $error';
    return format(value);
  }
}

/// Thrown on any parsing/evaluation failure.
class _CalcError implements Exception {
  final String message;
  _CalcError(this.message);
  @override
  String toString() => message;
}

/// The public calculator API.
class CalculatorEngine {
  const CalculatorEngine();

  /// Evaluate [expression] and return either a success or failure result.
  /// Set [degMode] to true (default) for degrees, false for radians.
  CalculatorResult evaluate(String expression, {bool degMode = true}) {
    if (expression.trim().isEmpty) {
      return CalculatorResult.failure('Empty expression');
    }
    try {
      final parser = _Parser(expression, degMode: degMode);
      final value = parser.parseExpression();
      if (parser._cur != _Tok.end) {
        throw _CalcError('Unexpected token at position ${parser.position}');
      }
      return CalculatorResult.success(value, expression.trim());
    } on _CalcError catch (e) {
      return CalculatorResult.failure(e.message);
    } on FormatException catch (e) {
      return CalculatorResult.failure(e.message);
    } catch (e) {
      return CalculatorResult.failure('Invalid expression: $e');
    }
  }

  /// Format a numeric value using the engine's display rules without
  /// running a parse — used by the keypad for live display.
  String formatNumber(double v) => CalculatorResult.format(v);
}

// ──────────────────────────────────────────────────────────────────────────
//  Tokenizer + recursive descent parser (combined, single pass)
// ──────────────────────────────────────────────────────────────────────────

enum _Tok { number, ident, op, lparen, rparen, comma, end }

class _Parser {
  final String src;
  int position = 0;
  final int length;
  final bool degMode;

  _Tok _cur = _Tok.end;
  double _numValue = 0;
  String _identValue = '';
  String _opValue = '';

  _Parser(this.src, {this.degMode = true}) : length = src.length {
    _advance();
  }

  double parseExpression() {
    var v = parseTerm();
    while (_cur == _Tok.op && (_opValue == '+' || _opValue == '-')) {
      final op = _opValue;
      _advance();
      final rhs = parseTerm();
      v = op == '+' ? v + rhs : v - rhs;
    }
    return v;
  }

  double parseTerm() {
    var v = parseFactor();
    while (_cur == _Tok.op &&
        (_opValue == '*' || _opValue == '/' || _opValue == '%')) {
      final op = _opValue;
      _advance();
      final rhs = parseFactor();
      if (op == '*') {
        v = v * rhs;
      } else if (op == '/') {
        if (rhs == 0) throw _CalcError('Division by zero');
        v = v / rhs;
      } else {
        if (rhs == 0) throw _CalcError('Modulo by zero');
        v = v % rhs;
      }
    }
    return v;
  }

  double parseFactor() {
    var v = parseUnary();
    while (_cur == _Tok.op && _opValue == '^') {
      _advance();
      final rhs = parseUnary();
      v = _pow(v, rhs);
    }
    return v;
  }

  double parseUnary() {
    if (_cur == _Tok.op && (_opValue == '+' || _opValue == '-')) {
      final op = _opValue;
      _advance();
      final v = parseUnary();
      return op == '-' ? -v : v;
    }
    return parsePrimary();
  }

  double parsePrimary() {
    if (_cur == _Tok.number) {
      final v = _numValue;
      _advance();
      if (_cur == _Tok.lparen || _cur == _Tok.ident) {
        final rhs = parsePrimary();
        return v * rhs;
      }
      return v;
    }

    if (_cur == _Tok.lparen) {
      _advance();
      final v = parseExpression();
      if (_cur != _Tok.rparen) {
        throw _CalcError('Expected closing parenthesis');
      }
      _advance();
      if (_cur == _Tok.lparen || _cur == _Tok.ident || _cur == _Tok.number) {
        final rhs = parsePrimary();
        return v * rhs;
      }
      return v;
    }

    if (_cur == _Tok.ident) {
      final name = _identValue.toLowerCase();
      _advance();
      if (_cur == _Tok.lparen) {
        _advance();
        final args = <double>[];
        if (_cur != _Tok.rparen) {
          args.add(parseExpression());
          while (_cur == _Tok.comma) {
            _advance();
            args.add(parseExpression());
          }
        }
        if (_cur != _Tok.rparen) {
          throw _CalcError('Expected ) after arguments');
        }
        _advance();
        final v = _callFunction(name, args);
        if (_cur == _Tok.lparen || _cur == _Tok.ident || _cur == _Tok.number) {
          final rhs = parsePrimary();
          return v * rhs;
        }
        return v;
      }
      return _resolveConstant(name);
    }

    throw _CalcError('Unexpected token at position $position');
  }

  // ── Function dispatch ──────────────────────────────────────────────
  double _toRad(double v) => degMode ? v * _deg2rad : v;
  double _fromRad(double v) => degMode ? v * _rad2deg : v;

  double _callFunction(String name, List<double> args) {
    final argc = args.length;
    switch (name) {
      // ── Trigonometric ──────────────────────────────────────────────
      case 'sin':
        _require(name, argc, 1);
        return math.sin(_toRad(args[0]));
      case 'cos':
        _require(name, argc, 1);
        return math.cos(_toRad(args[0]));
      case 'tan':
        _require(name, argc, 1);
        // In DEG mode, 90°/270°/... have no finite tan. We detect by checking
        // whether the angle (mod 180) is within floating-point tolerance of ±90.
        if (degMode) {
          final normalized = args[0] % 180.0;
          final absNorm = normalized.abs();
          if ((absNorm - 90.0).abs() < 1e-9) {
            throw _CalcError('tan(${args[0]}) is undefined');
          }
        }
        final t = math.tan(_toRad(args[0]));
        if (t.isInfinite || t.isNaN) throw _CalcError('tan() out of domain');
        return t;
      case 'asin':
        _require(name, argc, 1);
        if (args[0].abs() > 1) throw _CalcError('asin() domain: input must be in [-1, 1]');
        return _fromRad(math.asin(args[0]));
      case 'acos':
        _require(name, argc, 1);
        if (args[0].abs() > 1) throw _CalcError('acos() domain: input must be in [-1, 1]');
        return _fromRad(math.acos(args[0]));
      case 'atan':
        _require(name, argc, 1);
        return _fromRad(math.atan(args[0]));
      case 'atan2':
        _require(name, argc, 2);
        return _fromRad(math.atan2(args[0], args[1]));
      // ── Hyperbolic ─────────────────────────────────────────────────
      case 'sinh':
        _require(name, argc, 1);
        return _sinh(args[0]);
      case 'cosh':
        _require(name, argc, 1);
        return _cosh(args[0]);
      case 'tanh':
        _require(name, argc, 1);
        return _tanh(args[0]);
      case 'asinh':
        _require(name, argc, 1);
        return math.log(args[0] + math.sqrt(args[0] * args[0] + 1));
      case 'acosh':
        _require(name, argc, 1);
        if (args[0] < 1) throw _CalcError('acosh() domain: input must be >= 1');
        return math.log(args[0] + math.sqrt(args[0] * args[0] - 1));
      case 'atanh':
        _require(name, argc, 1);
        if (args[0].abs() >= 1) throw _CalcError('atanh() domain: |input| must be < 1');
        return 0.5 * math.log((1 + args[0]) / (1 - args[0]));
      // ── Logarithmic / exponential ───────────────────────────────────
      case 'log':
        _require(name, argc, 1);
        if (args[0] <= 0) throw _CalcError('log() domain: input must be > 0');
        return math.log(args[0]) / math.ln10;
      case 'log2':
        _require(name, argc, 1);
        if (args[0] <= 0) throw _CalcError('log2() domain: input must be > 0');
        return math.log(args[0]) / math.ln2;
      case 'ln':
        _require(name, argc, 1);
        if (args[0] <= 0) throw _CalcError('ln() domain: input must be > 0');
        return math.log(args[0]);
      case 'exp':
        _require(name, argc, 1);
        return math.exp(args[0]);
      // ── Roots / powers ──────────────────────────────────────────────
      case 'sqrt':
        _require(name, argc, 1);
        if (args[0] < 0) throw _CalcError('sqrt() domain: input must be >= 0');
        return math.sqrt(args[0]);
      case 'cbrt':
        _require(name, argc, 1);
        final vCbrt = args[0];
        return vCbrt < 0
            ? -math.pow(-vCbrt, 1 / 3).toDouble()
            : math.pow(vCbrt, 1 / 3).toDouble();
      case 'sq':
        // sq(x) = x²
        _require(name, argc, 1);
        return args[0] * args[0];
      case 'rec':
        // rec(x) = 1/x
        _require(name, argc, 1);
        if (args[0] == 0) throw _CalcError('rec(): division by zero');
        return 1.0 / args[0];
      // ── Rounding / sign ─────────────────────────────────────────────
      case 'abs':
        _require(name, argc, 1);
        return args[0].abs();
      case 'sign':
        _require(name, argc, 1);
        return args[0].sign;
      case 'round':
        _require(name, argc, 1);
        return args[0].roundToDouble();
      case 'floor':
        _require(name, argc, 1);
        return args[0].floorToDouble();
      case 'ceil':
        _require(name, argc, 1);
        return args[0].ceilToDouble();
      case 'trunc':
        _require(name, argc, 1);
        return args[0].truncateToDouble();
      // ── Factorial ───────────────────────────────────────────────────
      case 'fact':
        _require(name, argc, 1);
        final n = args[0];
        if (n < 0 || n != n.truncateToDouble()) {
          throw _CalcError('fact() requires a non-negative integer');
        }
        if (n > 170) throw _CalcError('fact(): overflow (max input 170)');
        return _factorial(n.toInt());
      // ── Variadic stats ──────────────────────────────────────────────
      case 'max':
        if (argc < 1) throw _CalcError('max() needs at least 1 argument');
        return args.reduce((a, b) => a > b ? a : b);
      case 'min':
        if (argc < 1) throw _CalcError('min() needs at least 1 argument');
        return args.reduce((a, b) => a < b ? a : b);
      case 'gcd':
        _require(name, argc, 2);
        return _gcd(args[0].abs().toInt(), args[1].abs().toInt()).toDouble();
      case 'lcm':
        _require(name, argc, 2);
        final a = args[0].abs().toInt();
        final b = args[1].abs().toInt();
        if (a == 0 || b == 0) return 0;
        return (a ~/ _gcd(a, b) * b).toDouble();
      default:
        throw _CalcError('Unknown function: $name');
    }
  }

  static double _factorial(int n) {
    if (n == 0 || n == 1) return 1.0;
    var result = 1.0;
    for (var i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  void _require(String fn, int got, int want) {
    if (got != want) {
      throw _CalcError('$fn() expects $want argument(s), got $got');
    }
  }

  double _resolveConstant(String name) {
    switch (name) {
      case 'pi':
        return math.pi;
      case 'e':
        return math.e;
      case 'phi':
        return 1.6180339887498949;
      case 'tau':
        return math.pi * 2;
      default:
        throw _CalcError('Unknown constant: $name');
    }
  }

  // ── Math primitives ─────────────────────────────────────────────────
  static const _deg2rad = 0.017453292519943295;
  static const _rad2deg = 57.29577951308232;

  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
  static double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
  static double _tanh(double x) {
    final ep = math.exp(x);
    final em = math.exp(-x);
    return (ep - em) / (ep + em);
  }

  static double _pow(double base, double exp) {
    if (base == 0) {
      if (exp > 0) return 0;
      if (exp == 0) return 1;
      throw _CalcError('0 raised to a negative power');
    }
    if (base < 0 && exp != exp.truncateToDouble()) {
      throw _CalcError('Negative base with fractional exponent');
    }
    return math.pow(base, exp).toDouble();
  }

  // ── Tokenizer (single step) ────────────────────────────────────────
  void _advance() {
    while (position < length && _isSpace(src[position])) {
      position++;
    }
    if (position >= length) {
      _cur = _Tok.end;
      return;
    }
    final ch = src[position];

    if (ch == '(') {
      _cur = _Tok.lparen;
      position++;
      return;
    }
    if (ch == ')') {
      _cur = _Tok.rparen;
      position++;
      return;
    }
    if (ch == ',') {
      _cur = _Tok.comma;
      position++;
      return;
    }

    if (_isDigit(ch) || ch == '.') {
      final start = position;
      var hasDot = false;
      var hasExp = false;
      while (position < length) {
        final c = src[position];
        if (_isDigit(c)) {
          position++;
        } else if (c == '.' && !hasDot && !hasExp) {
          hasDot = true;
          position++;
        } else if ((c == 'e' || c == 'E') && !hasExp && position > start) {
          var isScientific = false;
          if (position + 1 < length && _isDigit(src[position + 1])) {
            isScientific = true;
          } else if (position + 2 < length &&
              (src[position + 1] == '+' || src[position + 1] == '-') &&
              _isDigit(src[position + 2])) {
            isScientific = true;
          }
          if (isScientific) {
            hasExp = true;
            position++;
            if (position < length && (src[position] == '+' || src[position] == '-')) {
              position++;
            }
          } else {
            break;
          }
        } else {
          break;
        }
      }
      final raw = src.substring(start, position);
      _numValue = double.parse(raw);
      _cur = _Tok.number;
      return;
    }

    if (_isAlpha(ch)) {
      final start = position;
      while (position < length && _isAlnum(src[position])) {
        position++;
      }
      _identValue = src.substring(start, position);
      _cur = _Tok.ident;
      return;
    }

    if (ch == '+' || ch == '-' || ch == '*' || ch == '/' || ch == '%' || ch == '^') {
      _opValue = ch;
      _cur = _Tok.op;
      position++;
      return;
    }
    // Typographic operator variants
    if (ch == '×' || ch == '∙') {
      _opValue = '*';
      _cur = _Tok.op;
      position++;
      return;
    }
    if (ch == '÷') {
      _opValue = '/';
      _cur = _Tok.op;
      position++;
      return;
    }
    if (ch == '−') {
      _opValue = '-';
      _cur = _Tok.op;
      position++;
      return;
    }

    throw _CalcError('Unexpected character "$ch" at position $position');
  }

  static bool _isSpace(String c) =>
      c == ' ' || c == '\t' || c == '\n' || c == '\r';
  static bool _isDigit(String c) {
    final cu = c.codeUnitAt(0);
    return cu >= 48 && cu <= 57;
  }

  static bool _isAlpha(String c) {
    final cu = c.codeUnitAt(0);
    return (cu >= 65 && cu <= 90) || (cu >= 97 && cu <= 122) || c == '_';
  }

  static bool _isAlnum(String c) => _isAlpha(c) || _isDigit(c);
}
