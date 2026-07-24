class ReviewModel {
  final String id;
  final String claimId;
  final String materialId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? reviewerName;

  ReviewModel({
    required this.id,
    required this.claimId,
    required this.materialId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewerName,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    String? name;
    if (map['profiles'] != null && map['profiles'] is Map) {
      name = map['profiles']['display_name'] as String?;
    }

    return ReviewModel(
      id: map['id'] as String,
      claimId: map['claim_id'] as String,
      materialId: map['material_id'] as String,
      reviewerId: map['reviewer_id'] as String,
      revieweeId: map['reviewee_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      reviewerName: name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'claim_id': claimId,
      'material_id': materialId,
      'reviewer_id': reviewerId,
      'reviewee_id': revieweeId,
      'rating': rating,
      'comment': comment,
    };
  }
}
