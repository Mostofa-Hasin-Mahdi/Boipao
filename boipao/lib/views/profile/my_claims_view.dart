import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/claim_controller.dart';
import '../../controllers/review_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/add_review_dialog.dart';
import '../../widgets/neu_card.dart';
import '../chat/chat_view.dart';

class MyClaimsView extends StatefulWidget {
  const MyClaimsView({super.key});

  @override
  State<MyClaimsView> createState() => _MyClaimsViewState();
}

class _MyClaimsViewState extends State<MyClaimsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClaimController>().fetchMyClaims();
    });
  }

  void _handleCompleteClaim(String claimId) async {
    final success = await context.read<ClaimController>().updateClaimStatus(claimId, 'completed');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Claim marked as completed!")),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<ClaimController>().errorMessage ?? "Failed to update.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClaimController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Claims", style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
      ),
      body: controller.isLoading && controller.myClaims.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryCard))
          : controller.myClaims.isEmpty
              ? const Center(
                  child: Text(
                    "You haven't requested any materials yet.",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: controller.myClaims.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final claim = controller.myClaims[index];
                    final material = claim['materials'];
                    final status = claim['status'];

                    return NeuCard(
                      padding: 16.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                      material != null ? material['title'] : "Unknown Material",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Status: ${status.toUpperCase()}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: status == 'pending' ? AppColors.warning 
                                             : status == 'approved' ? AppColors.iconAccent 
                                             : AppColors.textSecondary
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          if (status == 'pending' || status == 'approved') ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatView(
                                        claimId: claim['id'],
                                        receiverId: material != null ? material['donor_id'] : '',
                                        title: material != null ? "Chat: ${material['title']}" : "Chat",
                                        isCompleted: false,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                                label: const Text("Chat with Donor"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.iconAccent,
                                  side: const BorderSide(color: AppColors.iconAccent),
                                ),
                              ),
                            ),
                          ] else if (status == 'completed') ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatView(
                                        claimId: claim['id'],
                                        receiverId: material != null ? material['donor_id'] : '',
                                        title: material != null ? "Chat: ${material['title']}" : "Chat",
                                        isCompleted: true,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.lock_clock_outlined, size: 18),
                                label: const Text("Resource Claimed - Chat Disabled"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.4)),
                                ),
                              ),
                            ),
                          ],

                          if (status == 'approved') ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryCard.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Your claim has been approved! Once you receive the material from the donor, please mark this as completed.",
                                style: TextStyle(fontSize: 13, color: AppColors.textMain),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.isLoading ? null : () => _handleCompleteClaim(claim['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.iconAccent,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Mark as Completed"),
                              ),
                            ),
                          ],

                          if (status == 'completed' && material != null) ...[
                            const SizedBox(height: 12),
                            FutureBuilder<bool>(
                              future: context.read<ReviewController>().hasClaimBeenReviewed(claim['id']),
                              builder: (context, snapshot) {
                                final isReviewed = snapshot.data ?? false;
                                if (isReviewed) {
                                  return const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: AppColors.iconAccent, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        "Reviewed",
                                        style: TextStyle(
                                          color: AppColors.iconAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final res = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AddReviewDialog(
                                          claimId: claim['id'],
                                          materialId: material['id'],
                                          revieweeId: material['donor_id'],
                                          materialTitle: material['title'],
                                        ),
                                      );
                                      if (res == true) {
                                        setState(() {});
                                      }
                                    },
                                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                                    label: const Text("Leave a Review"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textMain,
                                      side: const BorderSide(color: AppColors.primaryCard),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
