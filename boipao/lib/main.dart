import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'controllers/auth_controller.dart';
import 'controllers/material_controller.dart';
import 'core/theme/app_colors.dart';
import 'views/auth/auth_main_view.dart';
import 'views/main/main_view.dart';

/// The entry point for the BoiPao application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables securely
  await dotenv.load(fileName: ".env");

  // Initialize Supabase Live Connection
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Encapsulate the global application within our central state provider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => MaterialController()),
      ],
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



