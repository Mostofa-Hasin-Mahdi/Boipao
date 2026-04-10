import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NeuCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final double borderRadius;
  final Color? color;
  final bool isPressed;

  const NeuCard({
    super.key,
    required this.child,
    this.padding = 16.0,
    this.borderRadius = 16.0,
    this.color,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color ?? AppColors.background,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(inset, inset),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: const Offset(-inset, -inset),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: const Offset(6, 6),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: const Offset(-6, -6),
                  blurRadius: 12,
                ),
              ],
      ),
      child: child,
    );
  }
}

const double inset = 2.0; // Approximation for pressed state
