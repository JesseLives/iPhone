import 'package:flutter/material.dart';
import '../theme/app_style.dart';

enum BType { num, op, fn, eq, sci, zero }

class CalcButton extends StatefulWidget {
  final String value;
  final BType type;
  final bool dark;
  final bool small;
  final VoidCallback onPressed;

  const CalcButton({
    super.key,
    required this.value,
    required this.type,
    required this.dark,
    this.small = false,
    required this.onPressed,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dark;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: _bg(d),
              borderRadius: BorderRadius.circular(widget.small ? 12 : 16),
              border: widget.type == BType.op || widget.type == BType.eq
                  ? null
                  : Border.all(
                      color: (d ? AppColors.darkBorder : AppColors.border)
                          .withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                widget.value,
                style: jakarta(
                  widget.small ? 16 : (widget.value.length > 2 ? 22 : 26),
                  _fg(d),
                  FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _bg(bool d) => switch (widget.type) {
        BType.num || BType.zero => d ? AppColors.darkMuted : AppColors.muted,
        BType.op => AppColors.chart4,
        BType.fn => d ? AppColors.darkInput : AppColors.input,
        BType.eq => d ? AppColors.darkPrimary : AppColors.primary,
        BType.sci => d ? AppColors.darkAccent : AppColors.accent,
      };

  Color _fg(bool d) => switch (widget.type) {
        BType.num || BType.zero || BType.fn =>
          d ? AppColors.darkForeground : AppColors.foreground,
        BType.op || BType.eq => AppColors.primaryFg,
        BType.sci => d ? AppColors.darkAccentFg : AppColors.accentFg,
      };
}
