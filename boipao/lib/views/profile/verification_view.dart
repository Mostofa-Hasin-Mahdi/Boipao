import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/verification_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/neu_card.dart';

class VerificationView extends StatelessWidget {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerificationController(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Student Verification", style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textMain),
        ),
        body: Consumer<VerificationController>(
          builder: (context, controller, _) {
            if (controller.state == VerificationState.loading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryCard),
                    SizedBox(height: 16),
                    Text("Processing with Mistral AI...", style: TextStyle(color: AppColors.textMain)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Upload ID Card",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please upload a clear photo of your Student ID card. Our AI will automatically extract the details.",
                    style: TextStyle(color: AppColors.textMain.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 24),

                  if (controller.imageBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        controller.imageBytes!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    GestureDetector(
                      onTap: () => controller.pickAndProcessImage(),
                      child: NeuCard(
                        padding: 32.0,
                        child: Column(
                          children: [
                            Icon(Icons.camera_alt_rounded, size: 48, color: AppColors.textMain.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            const Text(
                              "Tap to Take Photo",
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  if (controller.state == VerificationState.error) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        controller.errorMessage ?? "An error occurred",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],

                  if (controller.state == VerificationState.success && controller.extractedData != null) ...[
                    const Text(
                      "Extracted Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 16),
                    NeuCard(
                      padding: 16.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow("School Name", controller.extractedData!['school_name']?.toString() ?? 'N/A'),
                          const Divider(),
                          _buildDetailRow("Class", controller.extractedData!['class_level']?.toString() ?? 'N/A'),
                          const Divider(),
                          _buildDetailRow("Roll Number", controller.extractedData!['roll_number']?.toString() ?? 'N/A'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Please verify that the extracted details are correct before submitting.",
                      style: TextStyle(color: Colors.orange.shade800, fontSize: 13, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 32),

                  if (controller.state == VerificationState.success) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.pickAndProcessImage(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.textMain,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Retake Photo", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await controller.submitVerification();
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Verification submitted successfully! Pending admin approval.")),
                                );
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryCard,
                              foregroundColor: AppColors.textMain,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textMain.withOpacity(0.6), fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
