import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'core/theme/app_colors.dart';
import 'views/auth/auth_main_view.dart';
import 'views/main/main_view.dart';

/// The entry point for the BoiPao application.
void main() {
  // Encapsulate the global application within our central state provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: const BoiPaoApp(),
    ),
  );
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
      // Automatically route between screens based on dummy login state dynamically
      home: Consumer<AuthController>(
        builder: (context, authController, _) {
          return authController.isLoggedIn ? const MainView() : const AuthMainView();
        },
      ),
    );
  }
}



