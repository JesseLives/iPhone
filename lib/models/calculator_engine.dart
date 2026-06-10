import 'dart:math';

class CalculatorEngine {
  static String evaluate(String expression) {
    try {
      String s = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      // Wrap π in parens so implicit multiplication works:
      // 2π → 2*(3.14…) not 23.14…
      s = s.replaceAll('π', '(${pi.toString()})');

      s = s.replaceAll('√', 'sqrt');

      // Percentage: 50% → (50/100)
      s = s.replaceAllMapped(
        RegExp(r'(\d+\.?\d*)%'),
        (m) => '(${m.group(1)}/100)',
      );

      // Balance parentheses by counting chars
      int open = 0, close = 0;
      for (final c in s.runes) {
        if (c == 0x28) open++;
        if (c == 0x29) close++;
      }
      for (int j = 0; j < open - close; j++) {
        s += ')';
      }

      final result = _ExpressionParser(s).parse().evaluate(_ContextModel());

      if (result.isNaN || result.isInfinite) return 'Error';

      // Use toStringAsFixed(0) for whole numbers to avoid toInt() overflow
      if (result == result.roundToDouble()) {
        if (result == 0) return '0';
        return result.toStringAsFixed(0);
      }
      String formatted = result.toStringAsFixed(10);
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      return formatted;
    } catch (_) {
      return 'Error';
    }
  }
}

// ─── AST ───────────────────────────────────────────

abstract class _Expr {
  double evaluate(_ContextModel ctx);
}

class _Num extends _Expr {
  final double v;
  _Num(this.v);
  @override
  double evaluate(_ContextModel ctx) => v;
}

class _Var extends _Expr {
  final String name;
  _Var(this.name);
  @override
  double evaluate(_ContextModel ctx) => ctx[name] ?? double.nan;
}

class _Bin extends _Expr {
  final _Expr l, r;
  final double Function(double, double) op;
  _Bin(this.l, this.r, this.op);
  @override
  double evaluate(_ContextModel ctx) => op(l.evaluate(ctx), r.evaluate(ctx));
}

class _Neg extends _Expr {
  final _Expr e;
  _Neg(this.e);
  @override
  double evaluate(_ContextModel ctx) => -e.evaluate(ctx);
}

class _Fn1 extends _Expr {
  final _Expr e;
  final double Function(double) fn;
  _Fn1(this.e, this.fn);
  @override
  double evaluate(_ContextModel ctx) => fn(e.evaluate(ctx));
}

// ─── Context ───────────────────────────────────────

class _ContextModel {
  static final _vars = <String, double>{'e': e, 'pi': pi};
  double? operator [](String name) => _vars[name];
}

// ─── Parser ────────────────────────────────────────
//
// Grammar (with implicit multiplication in _term):
//
//   expr  = term (('+' | '-') term)*
//   term  = power (('*' | '/' | <implicit>) power)*
//   power = unary ('^' power)?
//   unary = ('-' unary) | atom
//   atom  = '(' expr ')' | FUNC '(' expr ')' | NUMBER | VARIABLE
//
// <implicit> = next char is digit, letter, or '(' with no operator.
// This handles: 2(3), 2e, 2sin(x), (2)(3), (2)3, e2, esin(x), etc.

class _ExpressionParser {
  final String s;
  int i = 0;

  _ExpressionParser(this.s);

  _Expr parse() {
    final r = _expr();
    if (i < s.length) throw FormatException('Unexpected at $i');
    return r;
  }

  _Expr _expr() {
    var left = _term();
    while (_ch('+') || _ch('-')) {
      final op = s[i - 1];
      final right = _term();
      left = _Bin(left, right, op == '+' ? (a, b) => a + b : (a, b) => a - b);
    }
    return left;
  }

  _Expr _term() {
    var left = _power();
    while (true) {
      if (_ch('*') || _ch('/')) {
        final op = s[i - 1];
        final right = _power();
        left = _Bin(
            left,
            right,
            op == '*'
                ? (a, b) => a * b
                : (a, b) => b == 0
                    ? (a == 0 ? double.nan : double.infinity)
                    : a / b);
      } else if (_atomStart()) {
        // Implicit multiplication: 2(3), 2e, (2)(3), etc.
        final right = _power();
        left = _Bin(left, right, (a, b) => a * b);
      } else {
        break;
      }
    }
    return left;
  }

  /// Whether the current position looks like it could start an atom.
  /// Used for implicit multiplication detection.
  bool _atomStart() {
    if (i >= s.length) return false;
    final c = s[i];
    return _digit(c) || _alpha(c) || c == '(';
  }

  _Expr _power() {
    final base = _unary();
    if (_ch('^')) return _Bin(base, _power(), (a, b) => pow(a, b).toDouble());
    return base;
  }

  _Expr _unary() {
    if (_ch('-')) return _Neg(_unary());
    _ch('+');
    return _atom();
  }

  _Expr _atom() {
    _skip();

    if (_ch('(')) {
      final e = _expr();
      _ch(')');
      return e;
    }

    for (final (name, fn) in _funcs) {
      if (_word(name)) {
        _ch('(');
        final arg = _expr();
        _ch(')');
        return _Fn1(arg, fn);
      }
    }

    // Number
    final start = i;
    bool dot = false;
    while (i < s.length && (_digit(s[i]) || (s[i] == '.' && !dot))) {
      if (s[i] == '.') dot = true;
      i++;
    }
    if (i > start) return _Num(double.parse(s.substring(start, i)));

    // Variable
    final vs = i;
    while (i < s.length && _alpha(s[i])) i++;
    if (i > vs) return _Var(s.substring(vs, i));

    throw FormatException('Unexpected at $i');
  }

  static final _funcs = <(String, double Function(double))>[
    ('sqrt', sqrt),
    ('sin', sin),
    ('cos', cos),
    ('tan', tan),
    ('log', (v) => log(v) / ln10),
    ('ln', log),
  ];

  bool _ch(String c) {
    if (i < s.length && s[i] == c) { i++; return true; }
    return false;
  }

  bool _word(String w) {
    if (i + w.length <= s.length && s.substring(i, i + w.length) == w) {
      i += w.length;
      return true;
    }
    return false;
  }

  void _skip() { while (i < s.length && s[i] == ' ') i++; }

  bool _digit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _alpha(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 65 && u <= 90) || (u >= 97 && u <= 122);
  }
}
