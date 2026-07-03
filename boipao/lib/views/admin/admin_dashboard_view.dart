import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/neu_card.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminController(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Admin Dashboard", style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textMain),
        ),
        body: Consumer<AdminController>(
          builder: (context, controller, _) {
            if (controller.isLoading && controller.pendingVerifications.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryCard));
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Text(
                  "Error: ${controller.errorMessage}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (controller.pendingVerifications.isEmpty) {
              return const Center(
                child: Text(
                  "No pending verifications.",
                  style: TextStyle(color: AppColors.textMain, fontSize: 16),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchPendingVerifications,
              color: AppColors.primaryCard,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0).copyWith(bottom: 120),
                itemCount: controller.pendingVerifications.length,
                itemBuilder: (context, index) {
                  final verification = controller.pendingVerifications[index];
                  return _VerificationDetailCard(
                    verification: verification,
                    controller: controller,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VerificationDetailCard extends StatelessWidget {
  final Map<String, dynamic> verification;
  final AdminController controller;

  const _VerificationDetailCard({
    required this.verification,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final profile = verification['profiles'] ?? {};
    final displayName = profile['display_name'] ?? 'Unknown User';
    final email = profile['email'] ?? '';
    final imageUrl = verification['id_card_image_url'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: NeuCard(
        padding: 16.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.person, color: AppColors.textMain),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain)),
                      Text(email, style: TextStyle(color: AppColors.textMain.withOpacity(0.7), fontSize: 13)),
                    ],
                  ),
                ),
                Text(
                  "Pending",
                  style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            // Mistral Extracted Data
            const Text("AI Extracted Details", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryCard)),
            const SizedBox(height: 8),
            _buildInfoRow("School", verification['school_name']?.toString() ?? 'N/A'),
            _buildInfoRow("Class", verification['class_level']?.toString() ?? 'N/A'),
            _buildInfoRow("Roll", verification['roll_number']?.toString() ?? 'N/A'),
            const SizedBox(height: 16),

            // ID Card Image
            if (imageUrl.isNotEmpty) ...[
              const Text("ID Card Image", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  verification['signed_image_url'] ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Text("Image not found or already deleted."),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.isLoading ? null : () => _showConfirmation(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.isLoading ? null : () => _showConfirmation(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Approve"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 60, child: Text(label, style: TextStyle(color: AppColors.textMain.withOpacity(0.6), fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 13))),
        ],
      ),
    );
  }

  void _showConfirmation(BuildContext context, bool isApproved) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isApproved ? "Approve Verification?" : "Reject Verification?"),
        content: Text(
          isApproved 
              ? "This will verify the student and delete their ID card photo for privacy." 
              : "This will reject the request and delete their ID card photo."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await controller.processVerification(
                verification['id'], 
                verification['id_card_image_url'] ?? '', 
                isApproved
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isApproved ? "Verification Approved" : "Verification Rejected")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproved ? Colors.green : Colors.red,
            ),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
