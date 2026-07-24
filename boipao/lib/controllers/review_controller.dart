import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

enum ReviewState { initial, loading, success, error }

class ReviewController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  ReviewState _state = ReviewState.initial;
  ReviewState get state => _state;
  bool get isLoading => _state == ReviewState.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ReviewModel> _userReviews = [];
  List<ReviewModel> get userReviews => _userReviews;

  double _averageRating = 0.0;
  double get averageRating => _averageRating;

  final Set<String> _reviewedClaimIds = {};
  Set<String> get reviewedClaimIds => _reviewedClaimIds;

  void _setState(ReviewState state) {
    _state = state;
    notifyListeners();
  }

  /// Check if a claim has already been reviewed
  Future<bool> hasClaimBeenReviewed(String claimId) async {
    try {
      final res = await _supabase
          .from('reviews')
          .select('id')
          .eq('claim_id', claimId)
          .maybeSingle();
      if (res != null) {
        _reviewedClaimIds.add(claimId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Submit a review for a completed claim
  Future<bool> submitReview({
    required String claimId,
    required String materialId,
    required String revieweeId,
    required int rating,
    String? comment,
  }) async {
    try {
      _setState(ReviewState.loading);

      final currentUserId = _supabase.auth.currentUser!.id;

      await _supabase.from('reviews').insert({
        'claim_id': claimId,
        'material_id': materialId,
        'reviewer_id': currentUserId,
        'reviewee_id': revieweeId,
        'rating': rating,
        'comment': comment,
      });

      _reviewedClaimIds.add(claimId);
      _setState(ReviewState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ReviewState.error);
      return false;
    }
  }

  /// Fetch all reviews received by a user (e.g., donor)
  Future<void> fetchUserReviews(String userId) async {
    try {
      _setState(ReviewState.loading);

      final response = await _supabase
          .from('reviews')
          .select('*, profiles!reviews_reviewer_id_fkey(display_name)')
          .eq('reviewee_id', userId)
          .order('created_at', ascending: false);

      _userReviews = (response as List)
          .map((item) => ReviewModel.fromMap(item))
          .toList();

      if (_userReviews.isNotEmpty) {
        double total = 0;
        for (var r in _userReviews) {
          total += r.rating;
        }
        _averageRating = total / _userReviews.length;
      } else {
        _averageRating = 0.0;
      }

      _setState(ReviewState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ReviewState.error);
    }
  }
}
