import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../widgets/neu_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/material_model.dart';
import '../listings/listing_details_view.dart';

/// The core landing page for logged-in users.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final _supabase = Supabase.instance.client;
  List<MaterialModel> _recentListings = [];
  MaterialModel? _featuredMaterial;
  bool _isLoading = true;

  String? _lastLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Watch AuthController for changes
    final authController = context.watch<AuthController>();
    final currentLocation = authController.currentUser?.location;

    // If it's the first load, or if the user's location has changed since the last fetch
    if (_lastLocation != currentLocation) {
      _lastLocation = currentLocation;
      
      // Delaying the fetch slightly prevents setState during the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchRecentListings();
        fetchFeaturedMaterial();
      });
    }
  }

  Future<void> fetchFeaturedMaterial() async {
    try {
      final data = await _supabase
          .from('materials')
          .select('*, profiles(points)')
          .eq('status', 'available');
          
      if ((data as List).isNotEmpty) {
        final materialsList = List<Map<String, dynamic>>.from(data);
        
        materialsList.sort((a, b) {
          final pointsA = (a['profiles']?['points'] as int?) ?? 0;
          final pointsB = (b['profiles']?['points'] as int?) ?? 0;
          return pointsB.compareTo(pointsA);
        });
        
        if (mounted) {
          setState(() {
            _featuredMaterial = MaterialModel.fromJson(materialsList.first);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _featuredMaterial = null;
          });
        }
      }
    } catch (e) {
      // Ignore softly
    }
  }

  /// Fetches the 10 most recent available materials.
  /// First, it attempts to find materials within the user's specific location.
  /// If 0 materials are found, it falls back to a global search.
  Future<void> fetchRecentListings() async {
    try {
      final userLocation = context.read<AuthController>().currentUser?.location ?? '';
      
      // Base query
      var filterBuilder = _supabase
          .from('materials')
          .select()
          .eq('status', 'available');
          
      // If user has a location set, try fetching for that specific location first
      if (userLocation.isNotEmpty) {
        final localData = await filterBuilder
            .ilike('location', '%$userLocation%')
            .order('created_at', ascending: false)
            .limit(10);
        
        if ((localData as List).isNotEmpty) {
          if (mounted) {
            setState(() {
              _recentListings = localData.map((json) => MaterialModel.fromJson(json)).toList();
              _isLoading = false;
            });
          }
          return; // Exit early since we found local results!
        }
      }

      // Fallback: If no location is set, OR if 0 local results were found, do a global fetch
      final globalData = await filterBuilder
          .order('created_at', ascending: false)
          .limit(10);
      
      if (mounted) {
        setState(() {
          _recentListings = (globalData as List).map((json) => MaterialModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            
          if (_featuredMaterial != null) ...[
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListingDetailsView(material: _featuredMaterial!),
                  ),
                ).then((_) {
                  fetchRecentListings();
                  fetchFeaturedMaterial();
                });
              },
              child: NeuCard(
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
                      "${_featuredMaterial!.title}\nCondition: ${_featuredMaterial!.condition.label}",
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
            ),
          ],
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.iconAccent))
          else if (_recentListings.isEmpty)
            const Text("No recent listings found.", style: TextStyle(color: AppColors.textSecondary))
          else
            ..._recentListings.map((material) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildListingCard(material),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildListingCard(MaterialModel material) {
    final title = material.title;
    final subtitle = "${material.examType.label} • ${material.condition.label}";
    final location = material.location;
    final imageUrl = material.imageUrls.isNotEmpty ? material.imageUrls.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsView(material: material),
          ),
        );
      },
      child: NeuCard(
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
                image: imageUrl != null 
                    ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: imageUrl == null ? const Icon(Icons.menu_book_rounded, color: AppColors.iconAccent) : null,
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
      ),
    );
  }
}
