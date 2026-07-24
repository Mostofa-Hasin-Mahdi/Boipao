import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/review_controller.dart';
import '../core/theme/app_colors.dart';
import 'neu_card.dart';

class AddReviewDialog extends StatefulWidget {
  final String claimId;
  final String materialId;
  final String revieweeId;
  final String materialTitle;

  const AddReviewDialog({
    super.key,
    required this.claimId,
    required this.materialId,
    required this.revieweeId,
    required this.materialTitle,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() async {
    final controller = context.read<ReviewController>();
    final success = await controller.submitReview(
      claimId: widget.claimId,
      materialId: widget.materialId,
      revieweeId: widget.revieweeId,
      rating: _selectedRating,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thank you for your feedback!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.errorMessage ?? "Failed to submit review")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ReviewController>().isLoading;

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Review Material & Donor",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "How was your experience receiving '${widget.materialTitle}'?",
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            // Star rating bar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _selectedRating = starValue),
                  icon: Icon(
                    starValue <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.warning,
                    size: 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Comment input field
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textMain),
              decoration: InputDecoration(
                hintText: "Add an optional review comment...",
                hintStyle: TextStyle(color: AppColors.textMain.withOpacity(0.5)),
                filled: true,
                fillColor: AppColors.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: isLoading ? null : _submit,
                  child: NeuCard(
                    color: AppColors.primaryCard,
                    padding: 12.0,
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Submit",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
