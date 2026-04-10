import 'package:flutter/material.dart';

/// AppColors acts as our central theme dictionary.
/// All colors correspond to the soft UI, Neumorphic/Glassmorphic design.
class AppColors {
  static const Color background = Color(0xFFF9F7F6);   // Main Scaffolding color
  static const Color primaryCard = Color(0xFFCEE9BD);  // Accents and feature cards
  static const Color secondary = Color(0xFFE0D5CF);    // Unselected icons / accents
  static const Color darkCard = Color(0xFFBCC5AD);     // Inner shadows / darker elements
  static const Color textMain = Color(0xFF000000);     // Changed from grey to pure black for high contrast readability
  static const Color navBar = Color(0xFF050504);       // Solid black navigation bar
  static const Color iconAccent = Color(0xFF8BA07E);   // A deeply saturated, darker variant of primaryCard used specifically for colored icons
}
