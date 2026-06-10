import 'package:flutter/material.dart';
import '../theme/app_style.dart';

class DisplayArea extends StatelessWidget {
  final String expression;
  final String result;
  final Animation<double> scaleAnimation;
  final bool dark;

  const DisplayArea({
    super.key,
    required this.expression,
    required this.result,
    required this.scaleAnimation,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final fg = dark ? AppColors.darkForeground : AppColors.foreground;
    final mutedFg = dark ? AppColors.darkMutedFg : AppColors.mutedFg;
    final sz = result.length <= 8
        ? 52.0
        : result.length <= 12
            ? 40.0
            : result.length <= 16
                ? 32.0
                : 24.0;

    return Expanded(
      flex: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (expression.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  _formatExpr(expression),
                  style: jakarta(16, mutedFg, FontWeight.w400),
                  maxLines: 1,
                ),
              ),
            const SizedBox(height: 6),
            ScaleTransition(
              scale: scaleAnimation,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  result,
                  style: jakarta(sz, fg, FontWeight.w300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Insert spaces around operators for display only.
  static String _formatExpr(String e) => e
      .replaceAll('×', ' × ')
      .replaceAll('÷', ' ÷ ')
      .replaceAllMapped(RegExp(r'\+'), (m) => ' + ')
      .replaceAllMapped(RegExp(r'(?<=\d)-'), (m) => ' − ');
}
