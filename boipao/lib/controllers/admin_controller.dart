import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _pendingVerifications = [];
  List<Map<String, dynamic>> get pendingVerifications => _pendingVerifications;

  AdminController() {
    fetchPendingVerifications();
  }

  Future<void> fetchPendingVerifications() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase
          .from('student_verifications')
          .select('*, profiles!student_verifications_user_id_fkey(display_name, email)')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final verifications = List<Map<String, dynamic>>.from(response);
      
      // Generate signed URLs for private images
      for (var v in verifications) {
        final path = v['id_card_image_url'];
        if (path != null && path.toString().isNotEmpty) {
          try {
            final signedUrl = await _supabase.storage.from('id_cards').createSignedUrl(path, 60 * 60);
            v['signed_image_url'] = signedUrl;
          } catch (e) {
            debugPrint("Failed to create signed URL: $e");
          }
        }
      }

      _pendingVerifications = verifications;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> processVerification(String verificationId, String imageUrl, bool isApproved) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newStatus = isApproved ? 'approved' : 'rejected';

      // 1. Update the database status
      await _supabase
          .from('student_verifications')
          .update({'status': newStatus})
          .eq('id', verificationId);

      // 2. Delete the temporary image from the bucket
      if (imageUrl.isNotEmpty) {
        try {
          await _supabase.storage.from('id_cards').remove([imageUrl]);
        } catch (e) {
          debugPrint('Failed to delete image: $e');
          // We don't fail the approval if image deletion fails, 
          // but we log it for cleanup later.
        }
      }

      // 3. Remove from local list
      _pendingVerifications.removeWhere((v) => v['id'] == verificationId);
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
