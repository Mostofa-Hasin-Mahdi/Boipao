import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/claim_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/neu_card.dart';

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
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
