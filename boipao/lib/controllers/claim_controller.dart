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
      
      await _supabase.from('claims').insert({
        'material_id': materialId,
        'requester_id': userId,
        'status': 'pending',
      });

      _setState(ClaimState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      
      await _supabase
          .from('claims')
          .update({'status': newStatus})
          .eq('id', claimId);

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
