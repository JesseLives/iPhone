import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calc_history.dart';
import '../models/calculator_engine.dart' show CalculatorEngine;
import '../theme/app_style.dart';
import '../widgets/calc_button.dart';
import '../widgets/display_area.dart';

class CalculatorScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const CalculatorScreen({super.key, required this.prefs});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with TickerProviderStateMixin {
  /// Single source of truth: the raw expression string.
  String _expression = '';

  /// The evaluated result, set only by _evaluate().
  String _result = '';

  /// True after '=' produces a result. Digits start fresh; operators chain.
  bool _done = false;

  bool _isScientific = false;
  List<CalcHistory> _history = [];

  late AnimationController _resultAnim;
  late Animation<double> _resultScale;

  @override
  void initState() {
    super.initState();
    _history = CalcHistory.fromSharedPrefs(widget.prefs);
    _resultAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _resultScale = Tween(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _resultAnim, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _resultAnim.dispose();
    super.dispose();
  }

  // ── Display derivation ────────────────────────────
  // Derives what the large text should show from _expression alone.
  // No parallel tracking state.

  /// Small text: the expression being built. Hidden after '='.
  String get _exprDisplay => _done ? '' : _expression;

  /// Large text: current number while typing, or result after '='.
  String get _resultDisplay {
    if (_done) return _result;
    if (_expression.isEmpty) return '0';

    // Extract trailing number segment (digits and dots)
    final m = RegExp(r'[\d.]+$').firstMatch(_expression);
    if (m != null) return m.group(0)!;

    // Ends with operator/paren/etc — try live evaluation
    final r = CalculatorEngine.evaluate(_expression);
    return r != 'Error' ? r : _expression;
  }

  // ── Input handling ────────────────────────────────

  void _press(String v) {
    setState(() {
      switch (v) {
        // ── Digits ─────────────────────────────────
        case '0' || '1' || '2' || '3' || '4' ||
            '5' || '6' || '7' || '8' || '9':
          if (_done) {
            _expression = v;
            _done = false;
          } else {
            _expression += v;
          }

        // ── Decimal ────────────────────────────────
        case '.':
          if (_done) {
            // Don't chain from Error
            _expression = _result == 'Error' ? '0.' : '$_result.';
            _done = false;
            break;
          }
          if (_currentToken().contains('.')) break;
          _expression += '.';

        // ── Binary operators ───────────────────────
        case '+' || '-' || '×' || '÷':
          if (_done) {
            // Don't chain from Error — start from 0
            _expression = _result == 'Error' ? '0$v' : '$_result$v';
            _done = false;
          } else {
            _expression += v;
          }

        case '%':
          if (_expression.isNotEmpty) _expression += '%';

        case '^':
          _expression += '^';
          _done = false;

        // ── Scientific ─────────────────────────────
        case 'sin' || 'cos' || 'tan' || 'log' || 'ln':
          _expression += '$v(';
          _done = false;

        case '√':
          _expression += '√(';
          _done = false;

        case 'π':
          _expression = _done ? 'π' : _expression + 'π';
          _done = false;

        case 'e':
          _expression = _done ? 'e' : _expression + 'e';
          _done = false;

        case '(':
          _expression = _done ? '(' : _expression + '(';
          _done = false;

        case ')':
          _expression += ')';

        case 'x²':
          if (_expression.isNotEmpty) _expression += '^2';

        case 'xʸ':
          if (_expression.isNotEmpty) _expression += '^';

        // ── Actions ────────────────────────────────
        case 'AC':
          _expression = '';
          _result = '';
          _done = false;

        case '⌫':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
          }

        case '+/-':
          _toggleSign();

        case '=':
          _evaluate();
      }
    });
  }

  /// Trailing number token in _expression, used for double-dot check.
  String _currentToken() {
    final m = RegExp(r'[\d.]+$').firstMatch(_expression);
    return m?.group(0) ?? '';
  }

  void _toggleSign() {
    if (_done) {
      if (_result == 'Error') return; // no-op on error
      if (_result.startsWith('-')) {
        _result = _result.substring(1);
      } else if (_result != '0') {
        _result = '-$_result';
      }
      _expression = _result;
      return;
    }
    // Mid-expression: only negate if expression is a bare number
    if (RegExp(r'^-?\d+\.?\d*$').hasMatch(_expression)) {
      _expression = _expression.startsWith('-')
          ? _expression.substring(1)
          : '-$_expression';
    }
  }

  void _evaluate() {
    if (_expression.isEmpty) return;
    final r = CalculatorEngine.evaluate(_expression);
    if (r != 'Error') {
      _history.insert(0, CalcHistory(
        expression: _expression,
        result: r,
        timestamp: DateTime.now(),
      ));
      if (_history.length > 50) _history = _history.sublist(0, 50);
      CalcHistory.saveToSharedPrefs(widget.prefs, _history);
      _result = r;
      _expression = r;
      _done = true;
      _resultAnim.forward(from: 0);
    } else {
      _result = 'Error';
      _done = true;
    }
  }

  // ── Build ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final card = dark ? AppColors.darkCard : AppColors.card;

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(dark),
            DisplayArea(
              expression: _exprDisplay,
              result: _resultDisplay,
              scaleAnimation: _resultScale,
              dark: dark,
            ),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: card,
                  border: Border(top: BorderSide(color: border, width: 1)),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22.4)),
                ),
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                child:
                    _isScientific ? _sciKeypad(dark) : _stdKeypad(dark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────

  Widget _topBar(bool dark) {
    final mutedFg = dark ? AppColors.darkMutedFg : AppColors.mutedFg;
    final primary = dark ? AppColors.darkPrimary : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _topBtn(Icons.history_rounded, 'History', mutedFg, _showHistory),
          Row(children: [
            _topBtn(
              Icons.functions,
              _isScientific ? 'Basic' : 'Sci',
              _isScientific ? primary : mutedFg,
              () => setState(() => _isScientific = !_isScientific),
            ),
            const SizedBox(width: 4),
            _topBtn(
              dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              dark ? 'Light' : 'Dark',
              mutedFg,
              () {
                widget.prefs.setBool('isDarkMode', !dark);
                setState(() {});
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _topBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: jakarta(12, color, FontWeight.w500)),
        ]),
      ),
    );
  }

  // ── Keypads ───────────────────────────────────────

  Widget _stdKeypad(bool dark) {
    return _grid(
      [
        [('AC', BType.fn), ('+/-', BType.fn), ('%', BType.fn), ('÷', BType.op)],
        [('7', BType.num), ('8', BType.num), ('9', BType.num), ('×', BType.op)],
        [('4', BType.num), ('5', BType.num), ('6', BType.num), ('-', BType.op)],
        [('1', BType.num), ('2', BType.num), ('3', BType.num), ('+', BType.op)],
        [('0', BType.zero), ('.', BType.num), ('⌫', BType.fn), ('=', BType.eq)],
      ],
      dark,
    );
  }

  Widget _sciKeypad(bool dark) {
    return _grid(
      [
        [('sin', BType.sci), ('cos', BType.sci), ('tan', BType.sci), ('÷', BType.op)],
        [('log', BType.sci), ('ln', BType.sci), ('√', BType.sci), ('×', BType.op)],
        [('x²', BType.sci), ('xʸ', BType.sci), ('π', BType.sci), ('-', BType.op)],
        [('(', BType.sci), (')', BType.sci), ('e', BType.sci), ('+', BType.op)],
        [('AC', BType.fn), ('0', BType.num), ('.', BType.num), ('=', BType.eq)],
      ],
      dark,
      small: true,
    );
  }

  Widget _grid(List<List<(String, BType)>> rows, bool dark,
      {bool small = false}) {
    return Column(
      children: rows
          .map((row) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: row
                        .map((b) => Expanded(
                              flex: b.$2 == BType.zero ? 2 : 1,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: small ? 2.5 : 3.5),
                                child: CalcButton(
                                  value: b.$1,
                                  type: b.$2,
                                  dark: dark,
                                  small: small,
                                  onPressed: () => _press(b.$1),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ))
          .toList(),
    );
  }

  // ── History ───────────────────────────────────────

  void _showHistory() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _historySheet(dark),
    );
  }

  Widget _historySheet(bool dark) {
    final bg = dark ? AppColors.darkCard : AppColors.card;
    final fg = dark ? AppColors.darkForeground : AppColors.foreground;
    final mutedFg = dark ? AppColors.darkMutedFg : AppColors.mutedFg;
    final border = dark ? AppColors.darkBorder : AppColors.border;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      builder: (context, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(22.4)),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: mutedFg.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('History', style: jakarta(20, fg, FontWeight.w700)),
                  if (_history.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _history.clear();
                        CalcHistory.saveToSharedPrefs(widget.prefs, _history);
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: Text('Clear',
                          style: jakarta(
                              14, AppColors.destructive, FontWeight.w600)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _history.isEmpty
                  ? Center(
                      child: Text('No history yet',
                          style: jakarta(15, mutedFg, FontWeight.w400)))
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _history.length,
                      itemBuilder: (_, i) => _historyTile(_history[i], dark, () {
                        setState(() {
                          _expression = _history[i].result;
                          _result = _history[i].result;
                          _done = true;
                        });
                        Navigator.pop(context);
                      }),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyTile(CalcHistory h, bool dark, VoidCallback onTap) {
    final fg = dark ? AppColors.darkForeground : AppColors.foreground;
    final mutedFg = dark ? AppColors.darkMutedFg : AppColors.mutedFg;
    final secondary = dark ? AppColors.darkSecondary : AppColors.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: secondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(h.expression,
                    style: jakarta(13, mutedFg, FontWeight.w400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('= ${h.result}',
                    style: jakarta(18, fg, FontWeight.w600)),
              ])),
          Icon(Icons.replay_rounded, size: 16, color: mutedFg),
        ]),
      ),
    );
  }
}
