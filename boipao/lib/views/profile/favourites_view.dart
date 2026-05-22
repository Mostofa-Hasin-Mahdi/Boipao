import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/material_model.dart';
import '../../widgets/neu_card.dart';
import '../../controllers/auth_controller.dart';

class FavouritesView extends StatefulWidget {
  const FavouritesView({super.key});

  @override
  State<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView> {
  final _supabase = Supabase.instance.client;
  List<MaterialModel> _favourites = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFavourites();
  }

  Future<void> _fetchFavourites() async {
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;

    try {
      // Fetch material IDs from favourites table
      final favData = await _supabase
          .from('favourites')
          .select('material_id')
          .eq('user_id', user.id);

      if ((favData as List).isEmpty) {
        setState(() {
          _favourites = [];
          _isLoading = false;
        });
        return;
      }

      final materialIds = favData.map((e) => e['material_id'] as String).toList();

      // Fetch the actual materials
      final materialData = await _supabase
          .from('materials')
          .select()
          .inFilter('id', materialIds);

      setState(() {
        _favourites = (materialData as List).map((json) => MaterialModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        title: const Text('My Favourites', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.iconAccent))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _favourites.isEmpty
                  ? const Center(child: Text('You have no favourites yet.', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _favourites.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final material = _favourites[index];
                        return NeuCard(
                          padding: 16.0,
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade300,
                                  image: material.imageUrls.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(material.imageUrls.first),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: material.imageUrls.isEmpty
                                    ? const Icon(Icons.book, color: Colors.white, size: 40)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(material.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain)),
                                    const SizedBox(height: 4),
                                    Text(material.subject, style: const TextStyle(color: AppColors.textSecondary)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: AppColors.iconAccent),
                                        const SizedBox(width: 4),
                                        Expanded(child: Text(material.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
