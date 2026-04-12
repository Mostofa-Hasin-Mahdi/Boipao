import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../widgets/neu_card.dart';

/// The core landing page for logged-in users.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Tap into the Dummy Auth session to verify our Phase 2 role conditional logic
    final authController = context.watch<AuthController>();
    final roleName = authController.currentUser?.role.name.toUpperCase() ?? 'GUEST';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20).copyWith(bottom: 120),
        children: [
          Row(
            children: [
              Image.asset(
                'lib/assets/boipao.png',
                height: 38,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.menu_book_rounded, size: 30, color: AppColors.iconAccent),
              ),
              const SizedBox(width: 12),
              const Text(
                "BoiPao",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.textMain),
                onPressed: () => context.read<AuthController>().logout(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "Logged in as: $roleName",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textMain,
                ),
              ),
              if (authController.currentUser?.isVerified == true) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.navBar, // Solid black
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.warning, // The Beige warning color
                  ),
                ),
              ],
            ],
          ),
          
          // Phase 2 Validation: Admin specific block
          if (authController.currentUser?.role.name == 'admin')
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkCard.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.iconAccent, width: 2)
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: AppColors.textMain),
                  SizedBox(width: 8),
                  Expanded(child: Text("Admin Panel Dashboard Active. Validate OCR requests.", style: TextStyle(fontWeight: FontWeight.bold)))
                ],
              ),
            ),
            
          // Phase 2 Validation: Unverified General User Check  
          if (authController.currentUser?.role == UserRole.user && 
              !(authController.currentUser?.isVerified ?? true))
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.textMain),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "To donate or receive materials, you must verify that you're a student first.", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)
                    )
                  )
                ],
              ),
            ),
            
          const SizedBox(height: 24),
          NeuCard(
            color: AppColors.primaryCard,
            padding: 24.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Featured Material",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "HSC 2024 Physics Test Papers\nCondition: Like New",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textMain.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Claim Now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: NeuCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(Icons.volunteer_activism_rounded, size: 36, color: AppColors.iconAccent),
                          const SizedBox(height: 8),
                          const Text(
                            "Donate",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: NeuCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(Icons.search_rounded, size: 36, color: AppColors.iconAccent),
                          const SizedBox(height: 8),
                          const Text(
                            "Find Books",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Recent Listings",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 16),
          _buildListingCard("Panjaree Chemistry 1st Paper Test Paper", "HSC 25 Batch • Good Condition", "Mirpur, Dhaka"),
          const SizedBox(height: 16),
          _buildListingCard("Royal Physics 2nd Paper Guide", "HSC 24 Batch • Almost New", "Uttara, Dhaka"),
          const SizedBox(height: 16),
          _buildListingCard("Higher Math Notes by উদ্ভাস", "HSC 25 Batch • Excellent", "Dhanmondi, Dhaka"),
        ],
      ),
    );
  }

  Widget _buildListingCard(String title, String subtitle, String location) {
    return NeuCard(
      padding: 16.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.darkCard.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.iconAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMain.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.iconAccent),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
