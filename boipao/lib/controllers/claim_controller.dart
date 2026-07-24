import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ClaimState { initial, loading, success, error }

class ClaimController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  ClaimState _state = ClaimState.initial;
  ClaimState get state => _state;

  bool get isLoading => _state == ClaimState.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _myClaims = [];
  List<Map<String, dynamic>> get myClaims => _myClaims;

  List<Map<String, dynamic>> _incomingClaims = [];
  List<Map<String, dynamic>> get incomingClaims => _incomingClaims;

  void _setState(ClaimState state) {
    _state = state;
    notifyListeners();
  }

  /// Request a claim on a material
  Future<bool> requestClaim(String materialId) async {
    try {
      _setState(ClaimState.loading);
      
      final userId = _supabase.auth.currentUser!.id;

      // Get material & donor info
      final matRes = await _supabase
          .from('materials')
          .select('title, donor_id')
          .eq('id', materialId)
          .single();
      
      final donorId = matRes['donor_id'] as String?;
      final materialTitle = matRes['title'] as String? ?? 'Material';
      
      await _supabase.from('claims').insert({
        'material_id': materialId,
        'requester_id': userId,
        'status': 'pending',
      });

      if (donorId != null && donorId != userId) {
        try {
          // Fetch requester name
          final requesterRes = await _supabase
              .from('profiles')
              .select('display_name')
              .eq('id', userId)
              .maybeSingle();
          final requesterName = requesterRes?['display_name'] as String? ?? 'A student';

          await _supabase.from('notifications').insert({
            'user_id': donorId,
            'title': 'New Material Claim Request',
            'body': '$requesterName requested your material "$materialTitle".',
            'type': 'claim_request',
            'reference_id': materialId,
            'is_read': false,
          });
        } catch (e) {
          debugPrint('Error inserting notification: $e');
        }
      }

      _setState(ClaimState.success);
      return true;
    } catch (e) {
      if (e is PostgrestException && e.code == '23505') {
        _errorMessage = 'You have already requested this material.';
      } else {
        _errorMessage = 'Failed to request claim. Please try again.';
        debugPrint(e.toString());
      }
      _setState(ClaimState.error);
      return false;
    }
  }

  /// Fetch claims that the current user has made
  Future<void> fetchMyClaims() async {
    try {
      _setState(ClaimState.loading);
      
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('claims')
          .select('*, materials(*)')
          .eq('requester_id', userId)
          .order('created_at', ascending: false);

      _myClaims = List<Map<String, dynamic>>.from(response);
      _setState(ClaimState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ClaimState.error);
    }
  }

  /// Fetch claims made by others on a specific material owned by the user
  Future<void> fetchIncomingClaims(String materialId) async {
    try {
      _setState(ClaimState.loading);
      
      final response = await _supabase
          .from('claims')
          .select('*, profiles!claims_requester_id_fkey(display_name, email, is_verified, location)')
          .eq('material_id', materialId)
          .order('created_at', ascending: false);

      _incomingClaims = List<Map<String, dynamic>>.from(response);
      _setState(ClaimState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ClaimState.error);
    }
  }

  /// Update the status of a claim
  Future<bool> updateClaimStatus(String claimId, String newStatus, {String? materialId}) async {
    try {
      _setState(ClaimState.loading);
      
      // Fetch full claim info including requester_id and material
      final claimRes = await _supabase
          .from('claims')
          .select('*, materials(id, title, donor_id)')
          .eq('id', claimId)
          .single();

      await _supabase
          .from('claims')
          .update({'status': newStatus})
          .eq('id', claimId);

      final requesterId = claimRes['requester_id'] as String?;
      final material = claimRes['materials'] as Map<String, dynamic>?;
      final materialTitle = material?['title'] as String? ?? 'Material';
      final donorId = material?['donor_id'] as String?;

      if (newStatus == 'approved' && requesterId != null) {
        try {
          await _supabase.from('notifications').insert({
            'user_id': requesterId,
            'title': 'Claim Request Approved!',
            'body': 'Your request for "$materialTitle" has been approved by the donor.',
            'type': 'claim_approved',
            'reference_id': claimId,
            'is_read': false,
          });
        } catch (e) {
          debugPrint('Error inserting approved notification: $e');
        }
      } else if (newStatus == 'completed' && donorId != null) {
        try {
          // Fetch recipient name
          final currentUserId = _supabase.auth.currentUser!.id;
          final recipientRes = await _supabase
              .from('profiles')
              .select('display_name')
              .eq('id', currentUserId)
              .maybeSingle();
          final recipientName = recipientRes?['display_name'] as String? ?? 'Recipient';

          await _supabase.from('notifications').insert({
            'user_id': donorId,
            'title': 'Material Claim Completed!',
            'body': '$recipientName has received the material "$materialTitle". Thank you for donating!',
            'type': 'claim_completed',
            'reference_id': claimId,
            'is_read': false,
          });
        } catch (e) {
          debugPrint('Error inserting completed notification: $e');
        }
      }

      // If we provided materialId, refresh the incoming claims
      if (materialId != null) {
        await fetchIncomingClaims(materialId);
      } else {
        await fetchMyClaims();
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ClaimState.error);
      return false;
    }
  }
}
