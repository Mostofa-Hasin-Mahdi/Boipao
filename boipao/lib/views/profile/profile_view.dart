import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../widgets/neu_card.dart';
import '../listings/my_listings_view.dart';
import 'edit_profile_view.dart';
import 'favourites_view.dart';
import 'verification_view.dart';
import '../admin/admin_dashboard_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    if (user == null) {
      return const Center(child: Text("Please log in."));
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20).copyWith(bottom: 120),
        children: [
          // Header Section
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.secondary,
                child: const Icon(Icons.person, size: 40, color: AppColors.textMain),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.navBar,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: AppColors.warning,
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMain.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.iconAccent),
                        const SizedBox(width: 4),
                        Text(
                          user.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Edit Profile Action
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileView()),
              );
            },
            child: NeuCard(
              padding: 12.0,
              child: const Center(
                child: Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ),
          ),

          if (user.role == UserRole.user) ...[
            if (!user.isVerified) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VerificationView()),
                  );
                },
                child: NeuCard(
                  color: AppColors.primaryCard,
                  padding: 12.0,
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, color: AppColors.textMain),
                        SizedBox(width: 8),
                        Text(
                          "Verify Student ID",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // My Listings Action
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyListingsView()),
                );
              },
              child: NeuCard(
                padding: 12.0,
                child: const Center(
                  child: Text(
                    "My Listings",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // My Favourites Action
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavouritesView()),
                );
              },
              child: NeuCard(
                padding: 12.0,
                child: const Center(
                  child: Text(
                    "My Favourites",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          if (user.role == UserRole.user) ...[
            // Gamification Stats
            Row(
              children: [
                Expanded(
                  child: NeuCard(
                    color: AppColors.rewardGold,
                    padding: 16.0,
                    child: Column(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.navBar, size: 30),
                        const SizedBox(height: 8),
                        Text(
                          "${user.points}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navBar,
                          ),
                        ),
                        const Text(
                          "Points",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.navBar,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NeuCard(
                    padding: 16.0,
                    child: Column(
                      children: [
                        const Icon(Icons.volunteer_activism, color: AppColors.iconAccent, size: 30),
                        const SizedBox(height: 8),
                        Text(
                          "${user.donationsCount}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const Text(
                          "Donations",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMain,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NeuCard(
                    padding: 16.0,
                    child: Column(
                      children: [
                        const Icon(Icons.menu_book, color: AppColors.iconAccent, size: 30),
                        const SizedBox(height: 8),
                        Text(
                          "${user.claimsCount}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const Text(
                          "Claims",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMain,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityCard("Donated HSC Physics 2nd Paper", "2 days ago", Icons.check_circle_outline),
            const SizedBox(height: 16),
            _buildActivityCard("Claimed Oxford Dictionary", "1 week ago", Icons.hourglass_empty),
          ] else if (user.role == UserRole.admin) ...[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboardView()),
                );
              },
              child: NeuCard(
                color: AppColors.secondary,
                padding: 16.0,
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.admin_panel_settings, color: AppColors.secondary, size: 28),
                      SizedBox(width: 12),
                      Text(
                        "Open Admin Dashboard",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String subtitle, IconData icon) {
    return NeuCard(
      padding: 16.0,
      child: Row(
        children: [
          Icon(icon, color: AppColors.iconAccent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMain.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}
