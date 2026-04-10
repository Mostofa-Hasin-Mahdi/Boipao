import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'views/main/main_view.dart';

/// The entry point for the BoiPao application.
void main() {
  runApp(const BoiPaoApp());
}

/// The root application widget setting up global themes.
class BoiPaoApp extends StatelessWidget {
  const BoiPaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoiPao',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        // Using Google Fonts for a modern, sleek typography matching the soft UI
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryCard),
        useMaterial3: true,
      ),
      home: const MainView(),
    );
  }
}

