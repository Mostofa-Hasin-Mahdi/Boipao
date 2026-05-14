import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/material_model.dart';

class MaterialController extends ChangeNotifier {
  // We grab the global Supabase client here so we can talk to our live database
  final _supabase = Supabase.instance.client;
  
  // This list holds all the materials posted by the currently logged-in user.
  // We keep it private so UI components don't accidentally mess with it!
  List<MaterialModel> _myListings = [];
  
  // These help us show loading spinners and error messages in the UI
  bool _isLoading = false;
  String _errorMessage = '';

  // Public getters so the UI can safely read our state
  List<MaterialModel> get myListings => _myListings;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Fetches listings belonging to the currently logged in donor
  /// We call this whenever they open the 'My Listings' page.
  Future<void> fetchMyListings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _setLoading(true);
    try {
      final data = await _supabase
          .from('materials')
          .select()
          .eq('donor_id', user.id)
          .order('created_at', ascending: false);

      _myListings = (data as List).map((json) => MaterialModel.fromJson(json)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = "Failed to load listings: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  /// Uploads images to Supabase Storage and returns their public URLs
  Future<List<String>> _uploadImages(List<XFile> images) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    List<String> uploadedUrls = [];

    for (var image in images) {
      final fileExt = image.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.id}.$fileExt';
      final filePath = '${user.id}/$fileName'; // Store within a user-specific folder

      // Web-safe binary upload
      final bytes = await image.readAsBytes();
      await _supabase.storage.from('materials').uploadBinary(
        filePath, 
        bytes,
        fileOptions: FileOptions(contentType: 'image/$fileExt'),
      );
      
      final publicUrl = _supabase.storage.from('materials').getPublicUrl(filePath);
      uploadedUrls.add(publicUrl);
    }

    return uploadedUrls;
  }

  /// Creates a new material listing with associated images
  Future<bool> createListing({
    required String title,
    required String description,
    required ExamType examType,
    required String subject,
    required String year,
    required MaterialCondition condition,
    required String location,
    required List<XFile> images,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _errorMessage = "You must be logged in to create a listing.";
      return false;
    }

    _setLoading(true);
    try {
      List<String> imageUrls = await _uploadImages(images);

      final material = MaterialModel(
        id: '', // Supabase will auto-generate
        donorId: user.id,
        title: title,
        description: description,
        examType: examType,
        subject: subject,
        year: year,
        condition: condition,
        location: location,
        imageUrls: imageUrls,
        createdAt: DateTime.now(), // Local placeholder
      );

      // Insert directly
      await _supabase.from('materials').insert(material.toJson());

      // Refresh list
      await fetchMyListings();
      return true;
    } catch (e) {
      _errorMessage = "Failed to create listing: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing material listing
  Future<bool> updateListing({
    required MaterialModel oldMaterial,
    required String title,
    required String description,
    required ExamType examType,
    required String subject,
    required String year,
    required MaterialCondition condition,
    required String location,
    // Note: We are keeping image updates simple for now. If they want to change images, they'll have to delete and recreate, or we can add complex image sync logic later.
  }) async {
    _setLoading(true);
    try {
      final updatedData = {
        'title': title,
        'description': description,
        'exam_type': examType.label,
        'subject': subject,
        'year': year,
        'condition': condition.value,
        'location': location,
        // status and image_urls stay the same
      };

      await _supabase.from('materials').update(updatedData).eq('id', oldMaterial.id);
      
      // Refresh local list
      await fetchMyListings();
      return true;
    } catch (e) {
      _errorMessage = "Failed to update listing: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a material listing and its associated images from storage
  Future<bool> deleteListing(MaterialModel material) async {
    _setLoading(true);
    try {
      // Clean up storage images first
      if (material.imageUrls.isNotEmpty) {
        // Extract paths from URLs
        final bucketUrl = _supabase.storage.from('materials').getPublicUrl('');
        List<String> pathsToDelete = material.imageUrls.map((url) {
          return url.replaceFirst(bucketUrl, '');
        }).toList();

        await _supabase.storage.from('materials').remove(pathsToDelete);
      }

      // Delete from database
      await _supabase.from('materials').delete().eq('id', material.id);
      
      // Update local state
      _myListings.removeWhere((item) => item.id == material.id);
      _errorMessage = '';
      return true;
    } catch (e) {
      _errorMessage = "Failed to delete listing: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
