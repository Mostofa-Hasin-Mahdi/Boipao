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
import 'my_claims_view.dart';
import '../../controllers/review_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<ReviewController>().fetchUserReviews(user.id);
      }
    });
  }

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
            // My Claims Action
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyClaimsView()),
                );
              },
              child: NeuCard(
                padding: 12.0,
                child: const Center(
                  child: Text(
                    "My Claims",
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
            
            // Badges Section
            const Text(
              "Badges",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            NeuCard(
              padding: 16.0,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (user.isVerified)
                    _buildBadge("Verified Student", Icons.verified_rounded, Colors.blue),
                  if (user.donationsCount >= 1)
                    _buildBadge("First Donation", Icons.volunteer_activism_rounded, Colors.pink),
                  if (user.donationsCount >= 5)
                    _buildBadge("Generous Donor", Icons.diamond_rounded, Colors.purple),
                  if (user.points >= 100)
                    _buildBadge("Elite Donor", Icons.military_tech_rounded, Colors.amber.shade800),
                  if (!user.isVerified && user.donationsCount == 0 && user.points == 0)
                    const Text("Complete activities to earn badges!", style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Reviews Section
            const Text(
              "Recent Reviews",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ReviewController>(
              builder: (context, reviewController, _) {
                if (reviewController.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.iconAccent));
                }
                
                if (reviewController.userReviews.isEmpty) {
                  return const NeuCard(
                    padding: 16.0,
                    child: Center(
                      child: Text("No reviews received yet.", style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  );
                }
                
                return Column(
                  children: reviewController.userReviews.map((review) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: NeuCard(
                        padding: 16.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: index < review.rating ? Colors.orange.shade400 : Colors.grey.shade300,
                                    );
                                  }),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(review.createdAt),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (review.comment != null && review.comment!.isNotEmpty)
                              Text(
                                review.comment!,
                                style: const TextStyle(fontSize: 14, color: AppColors.textMain),
                              )
                            else
                              const Text(
                                "No comment provided.",
                                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              "- ${review.reviewerName ?? 'Anonymous'}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
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

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }

}
