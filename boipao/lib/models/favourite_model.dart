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

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      materialId: json['material_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'material_id': materialId,
    };
  }
}
