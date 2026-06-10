import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalcHistory {
  final String expression;
  final String result;
  final DateTime timestamp;

  CalcHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'expression': expression,
        'result': result,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CalcHistory.fromJson(Map<String, dynamic> json) => CalcHistory(
        expression: json['expression'] as String? ?? '',
        result: json['result'] as String? ?? '0',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );

  /// Loads history from SharedPreferences.
  /// Corrupted entries are silently skipped.
  static List<CalcHistory> fromSharedPrefs(SharedPreferences prefs) {
    final data = prefs.getStringList('calcHistory') ?? [];
    final List<CalcHistory> out = [];
    for (final raw in data) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          out.add(CalcHistory.fromJson(decoded));
        }
      } catch (_) {
        // Skip corrupted entries
      }
    }
    return out;
  }

  static void saveToSharedPrefs(
      SharedPreferences prefs, List<CalcHistory> history) {
    prefs.setStringList(
      'calcHistory',
      history.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
