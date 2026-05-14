/// User roles simplified based on the updated specification.
/// A general user can both receive or donate.
enum UserRole {
  user,
  admin,
}

/// A class representing a mapped Supabase profile.
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isVerified;
  
  final String location;
  final int points;
  final int donationsCount;
  final int claimsCount;
  
  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.isVerified = false,
    this.location = "Dhaka, Bangladesh",
    this.points = 0,
    this.donationsCount = 0,
    this.claimsCount = 0,
  });

  /// Allows updating specific fields while keeping others unchanged.
  UserModel copyWith({
    String? displayName,
    String? location,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role,
      isVerified: isVerified,
      location: location ?? this.location,
      points: points,
      donationsCount: donationsCount,
      claimsCount: claimsCount,
    );
  }

  /// Parses JSON from the Supabase `profiles` table.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Determine role from postgres enum string
    UserRole parsedRole = UserRole.user;
    if (json['role'] == 'admin') {
      parsedRole = UserRole.admin;
    }

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? 'Unknown User',
      role: parsedRole,
      isVerified: json['is_verified'] as bool? ?? false,
      location: json['location'] as String? ?? 'Dhaka, Bangladesh',
      points: json['points'] as int? ?? 0,
      donationsCount: json['donations_count'] as int? ?? 0,
      claimsCount: json['claims_count'] as int? ?? 0,
    );
  }
}
