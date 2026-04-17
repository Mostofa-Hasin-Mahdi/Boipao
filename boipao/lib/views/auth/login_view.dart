import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/neu_card.dart';

/// The login screen simulating authentication for Multiple Role tests.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _handleLogin() {
    final authController = context.read<AuthController>();
    final success = authController.login(_emailController.text, _passwordController.text);
    if (!success) {
      setState(() {
        _errorMessage = 'Invalid credentials. Try user@boipao.com or verified@boipao.com';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0).copyWith(bottom: 120),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo & Title Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/boipao.png',
                    height: 50,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.menu_book_rounded, size: 40, color: AppColors.iconAccent),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "BoiPao",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Sign in to start sharing knowledge",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textMain,
                ),
              ),
              
              const SizedBox(height: 60),

              // Login Form Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "user@boipao.com",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // Sign In Button
              GestureDetector(
                onTap: _handleLogin,
                child: NeuCard(
                  color: AppColors.primaryCard,
                  padding: 16.0,
                  child: const Center(
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
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
