/// Represents a user's favourited material listing.
/// Maps directly to the `favourites` table in Supabase.
class FavouriteModel {
  final String id;
  final String userId;
  final String materialId;
  final DateTime createdAt;

  const FavouriteModel({
    required this.id,
    required this.userId,
    required this.materialId,
    required this.createdAt,
  });

  /// Parses JSON from the Supabase `favourites` table.
  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      materialId: json['material_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts the model back into a Supabase-compatible JSON map for insert.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'material_id': materialId,
    };
  }
}
