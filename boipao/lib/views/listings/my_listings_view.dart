import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/neu_card.dart';
import '../../controllers/material_controller.dart';
import '../../models/material_model.dart';
import 'edit_listing_view.dart';

class MyListingsView extends StatefulWidget {
  const MyListingsView({super.key});

  @override
  State<MyListingsView> createState() => _MyListingsViewState();
}

class _MyListingsViewState extends State<MyListingsView> {
  @override
  void initState() {
    super.initState();
    // Fetch listings when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialController>().fetchMyListings();
    });
  }

  void _confirmDelete(MaterialModel material) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('Delete Listing', style: TextStyle(color: AppColors.textMain)),
        content: const Text('Are you sure you want to permanently delete this material?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.iconAccent)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<MaterialController>().deleteListing(material);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Listing deleted.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.read<MaterialController>().errorMessage, style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaterialController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        title: const Text('My Listings', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
      ),
      body: controller.isLoading && controller.myListings.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.iconAccent))
          : controller.myListings.isEmpty
              ? const Center(
                  child: Text(
                    "You haven't posted any materials yet.\nTap the + button to get started!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.iconAccent, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: controller.myListings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final material = controller.myListings[index];
                    return NeuCard(
                      padding: 16.0,
                      child: Row(
                        children: [
                          // Thumbnail
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryCard,
                              borderRadius: BorderRadius.circular(12),
                              image: material.imageUrls.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(material.imageUrls.first),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: material.imageUrls.isEmpty
                                ? const Icon(Icons.menu_book, color: AppColors.iconAccent, size: 32)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  material.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${material.examType.label} • ${material.subject}",
                                  style: TextStyle(color: AppColors.textMain.withOpacity(0.7), fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      material.status == MaterialStatus.available ? Icons.check_circle : Icons.hourglass_empty,
                                      size: 14,
                                      color: material.status == MaterialStatus.available ? AppColors.iconAccent : AppColors.warning,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      material.status.value.toUpperCase(),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMain),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          // Actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.iconAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => EditListingView(material: material)),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(material),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
