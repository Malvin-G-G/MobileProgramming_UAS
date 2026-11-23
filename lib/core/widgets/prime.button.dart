import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PrimeButton extends StatefulWidget {
  const PrimeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.edgeColor = AppColors.primaryDark,
    this.textColor = Colors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color edgeColor;
  final Color textColor;

  @override
  State<PrimeButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimeButton> {
  static const double _height = 52;
  static const double _depth = 4;

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final face = enabled ? widget.color : AppColors.disabled;
    final edge = enabled ? widget.edgeColor : AppColors.disabledEdge;
    final text = enabled ? widget.textColor : AppColors.textSecondary;
    final radius = BorderRadius.circular(16);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTap: widget.onPressed,
      child: SizedBox(
        height: _height + _depth,
        width: double.infinity,
        child: Stack(
          children: [

            Positioned(
              left: 0,
              right: 0,
              top: _depth,
              height: _height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: edge, borderRadius: radius),
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 80),
              left: 0,
              right: 0,
              top: _pressed ? _depth : 0,
              height: _height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: face, borderRadius: radius),
                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}