import 'package:flutter/material.dart';

/// A clean, elevated white card used consistently across the app.
/// 
/// Replaces the primary neumorphic pattern with a modern, crisp elevated 
/// design using a soft drop shadow, placed over the cream white background.
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
        color: color ?? Colors.white, // Plain white background for pure, soft look
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Clean, subtle uplifting shadow
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

const double inset = 2.0; // Approximation for pressed state
