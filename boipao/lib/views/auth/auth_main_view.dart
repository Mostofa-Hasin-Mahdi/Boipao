import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/auth_nav_bar.dart';
import 'login_view.dart';
import 'signup_view.dart';

/// Hosts the Login and Signup views and manages switching between them via the dock.
class AuthMainView extends StatefulWidget {
  const AuthMainView({super.key});

  @override
  State<AuthMainView> createState() => _AuthMainViewState();
}

class _AuthMainViewState extends State<AuthMainView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const LoginView(),
    const SignupView(),
  ];

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true, // Let the body content scroll behind the floating dock
      body: Stack(
        children: [
          // We wrap the pages in an AnimatedSwitcher for a smooth fade
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_currentIndex],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AuthNavBar(
              selectedIndex: _currentIndex,
              onItemSelected: _changeTab,
            ),
          ),
        ],
      ),
    );
  }
}
