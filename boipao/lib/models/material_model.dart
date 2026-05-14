/// Enum mapping for Postgres `exam_type`
enum ExamType {
  ssc('SSC'),
  hsc('HSC'),
  other('Other');

  final String label;
  const ExamType(this.label);

  factory ExamType.fromString(String val) {
    return ExamType.values.firstWhere(
      (e) => e.label.toUpperCase() == val.toUpperCase(),
      orElse: () => ExamType.other,
    );
  }
}

/// Enum mapping for Postgres `material_condition`
enum MaterialCondition {
  newCondition('new', 'New'),
  likeNew('like_new', 'Like New'),
  good('good', 'Good'),
  fair('fair', 'Fair'),
  poor('poor', 'Poor');

  final String value;
  final String label;
  const MaterialCondition(this.value, this.label);

  factory MaterialCondition.fromString(String val) {
    return MaterialCondition.values.firstWhere(
      (e) => e.value == val,
      orElse: () => MaterialCondition.good,
    );
  }
}

/// Enum mapping for Postgres `material_status`
enum MaterialStatus {
  available('available'),
  pending('pending'),
  claimed('claimed');

  final String value;
  const MaterialStatus(this.value);

  factory MaterialStatus.fromString(String val) {
    return MaterialStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => MaterialStatus.available,
    );
  }
}

/// A class representing a mapped Supabase material listing.
class MaterialModel {
  final String id;
  final String donorId;
  final String title;
  final String description;
  final ExamType examType;
  final String subject;
  final String year;
  final MaterialCondition condition;
  final String location;
  final List<String> imageUrls;
  final MaterialStatus status;
  final DateTime createdAt;

  const MaterialModel({
    required this.id,
    required this.donorId,
    required this.title,
    this.description = '',
    required this.examType,
    required this.subject,
    this.year = '',
    required this.condition,
    required this.location,
    this.imageUrls = const [],
    this.status = MaterialStatus.available,
    required this.createdAt,
  });

  /// Parses JSON from the Supabase `materials` table.
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as String,
      donorId: json['donor_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      examType: ExamType.fromString(json['exam_type'] as String),
      subject: json['subject'] as String,
      year: json['year'] as String? ?? '',
      condition: MaterialCondition.fromString(json['condition'] as String),
      location: json['location'] as String,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      status: MaterialStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts the model back into a Supabase-compatible JSON map for insert/update.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'donor_id': donorId,
      'title': title,
      'description': description,
      'exam_type': examType.label,
      'subject': subject,
      'year': year,
      'condition': condition.value,
      'location': location,
      'image_urls': imageUrls,
      'status': status.value,
    };
  }
}
