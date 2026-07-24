import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/claim_controller.dart';
import '../../models/material_model.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/neu_card.dart';
import '../chat/chat_view.dart';

class ListingDetailsView extends StatefulWidget {
  final MaterialModel material;
  
  const ListingDetailsView({super.key, required this.material});

  @override
  State<ListingDetailsView> createState() => _ListingDetailsViewState();
}

class _ListingDetailsViewState extends State<ListingDetailsView> {
  @override
  void initState() {
    super.initState();
    // If the current user is the donor, fetch incoming claims
    final currentUser = context.read<AuthController>().currentUser;
    if (currentUser?.id == widget.material.donorId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ClaimController>().fetchIncomingClaims(widget.material.id);
      });
    }
  }

  bool _isRequesting = false;

  void _handleClaimRequest() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    final success = await context.read<ClaimController>().requestClaim(widget.material.id);
    
    if (mounted) {
      setState(() => _isRequesting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Material claimed successfully!")),
        );
        Navigator.pop(context); // Go back after claiming
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<ClaimController>().errorMessage ?? "Failed to claim material.")),
        );
      }
    }
  }

  void _handleClaimStatusUpdate(String claimId, String status) async {
    final success = await context.read<ClaimController>().updateClaimStatus(
      claimId, 
      status, 
      materialId: widget.material.id
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Claim $status successfully!")),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<ClaimController>().errorMessage ?? "Failed to update claim.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthController>().currentUser;
    final isDonor = currentUser?.id == widget.material.donorId;
    final claimController = context.watch<ClaimController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Material Details", style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Material Image
          if (widget.material.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.material.imageUrls.first,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.darkCard.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.menu_book_rounded, size: 80, color: AppColors.iconAccent),
            ),
          
          const SizedBox(height: 24),
          
          // Material Info
          Text(
            widget.material.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.material.status.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMain),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.material.condition.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMain),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow(Icons.school_rounded, "Exam Type: ${widget.material.examType.label}"),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.book_rounded, "Subject: ${widget.material.subject}"),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_rounded, "Location: ${widget.material.location}"),
          
          const SizedBox(height: 24),
          
          if (widget.material.description.isNotEmpty) ...[
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            const SizedBox(height: 8),
            Text(
              widget.material.description,
              style: TextStyle(fontSize: 15, color: AppColors.textMain.withOpacity(0.8), height: 1.5),
            ),
            const SizedBox(height: 32),
          ],
          
          // ACTIONS
          if (!isDonor) ...[
            // Recipient View
            if (currentUser?.isVerified == true && widget.material.status == MaterialStatus.available)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (claimController.isLoading || _isRequesting) ? null : _handleClaimRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCard,
                    foregroundColor: AppColors.textMain,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: (claimController.isLoading || _isRequesting)
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.textMain, strokeWidth: 2))
                      : const Text("Request Material", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            else if (currentUser?.isVerified == false)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "You must verify your student ID in the Profile tab before you can claim materials.",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
                  textAlign: TextAlign.center,
                ),
              )
            else if (widget.material.status != MaterialStatus.available)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "This material is currently ${widget.material.status.name}.",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
                  textAlign: TextAlign.center,
                ),
              ),
          ] else ...[
            // Donor View: Incoming Claims
            const Text(
              "Incoming Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            const SizedBox(height: 12),
            
            if (claimController.isLoading && claimController.incomingClaims.isEmpty)
              const Center(child: CircularProgressIndicator(color: AppColors.iconAccent))
            else if (claimController.incomingClaims.isEmpty)
              const Text("No requests yet.", style: TextStyle(color: AppColors.textSecondary))
            else
              ...claimController.incomingClaims.map((claim) => _buildClaimCard(claim, claimController.isLoading)),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.iconAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: AppColors.textMain),
          ),
        ),
      ],
    );
  }

  Widget _buildClaimCard(Map<String, dynamic> claim, bool isLoading) {
    final requester = claim['profiles'];
    final status = claim['status'];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: NeuCard(
        padding: 16.0,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: Icon(Icons.person_rounded, color: AppColors.textMain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requester['display_name'] ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain),
                    ),
                    Text(
                      "Status: ${status.toUpperCase()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: status == 'pending' ? AppColors.warning : AppColors.iconAccent
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
                        receiverId: claim['requester_id'],
                        title: "Chat with ${requester['display_name'] ?? 'User'}",
                        isCompleted: false,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text("Chat with Requester"),
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
                        receiverId: claim['requester_id'],
                        title: "Chat with ${requester['display_name'] ?? 'User'}",
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

          if (status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => _handleClaimStatusUpdate(claim['id'], 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _handleClaimStatusUpdate(claim['id'], 'approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.iconAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Approve"),
                  ),
                ),
              ],
            )
          ] else if (status == 'approved') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primaryCard.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
              child: Text(
                "Approved! You should contact ${requester['display_name']} at ${requester['email']}",
                style: const TextStyle(fontSize: 13, color: AppColors.textMain),
              ),
            ),
          ]
        ],
      ),
      ),
    );
  }
}
