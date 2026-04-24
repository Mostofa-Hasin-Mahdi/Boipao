/// User roles simplified based on the updated specification.
/// A general user can both receive or donate.
enum UserRole {
  user,
  admin,
}

/// A dummy user class replicating what a Supabase Auth User or custom user profile will look like.
/// 
/// Extended for Phase 3 to track location and gamification stats.
class DummyUser {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isVerified;
  
  final String location;
  final int points;
  final int donationsCount;
  final int claimsCount;
  
  const DummyUser({
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
  DummyUser copyWith({
    String? displayName,
    String? location,
  }) {
    return DummyUser(
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

  /// A helper method to quickly construct dummy user mock profiles for our UI verification
  factory DummyUser.mock(String email, UserRole role, {bool isVerified = false}) {
    switch (role) {
      case UserRole.user:
        return DummyUser(
          id: '1', 
          email: email, 
          displayName: isVerified ? 'Verified Student' : 'Unverified User', 
          role: UserRole.user,
          isVerified: isVerified,
          location: 'Uttara, Dhaka',
          points: isVerified ? 120 : 0,
          donationsCount: isVerified ? 12 : 0,
          claimsCount: isVerified ? 3 : 0,
        );
      case UserRole.admin:
        return DummyUser(
          id: '2', 
          email: email, 
          displayName: 'System Admin', 
          role: UserRole.admin,
          isVerified: true, // Admins are always verified by default
          location: 'HQ',
          points: 999,
          donationsCount: 50,
          claimsCount: 0,
        );
    }
  }
}
