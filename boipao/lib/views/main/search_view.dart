import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/material_model.dart';
import '../../widgets/neu_card.dart';
import '../listings/listing_details_view.dart';

/// A dedicated view for searching through available material listings.
/// Users can search by title using Supabase's full-text/ilike search capabilities.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  final _supabase = Supabase.instance.client;
  
  List<MaterialModel> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  /// Executes the search query against the Supabase `materials` table.
  /// Uses an `ilike` filter to find partial matches in the material's title.
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _supabase
          .from('materials')
          .select()
          .eq('status', 'available')
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      setState(() {
        _searchResults = (data as List).map((json) => MaterialModel.fromJson(json)).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
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
        title: const Text('Search Materials', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            NeuCard(
              padding: 4.0,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by title...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.iconAccent),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _performSearch,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.iconAccent))
            else if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red))
            else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
              const Center(child: Text('No results found.', style: TextStyle(color: AppColors.textSecondary)))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final material = _searchResults[index];
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
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
