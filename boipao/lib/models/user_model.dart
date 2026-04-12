/// User roles simplified based on the updated specification.
/// A general user can both receive or donate.
enum UserRole {
  user,
  admin,
}

/// A dummy user class replicating what a Supabase Auth User or custom user profile will look like.
/// 
/// Added [isVerified] to strictly track if a general user has completed the student OCR verification.
class DummyUser {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isVerified;
  
  const DummyUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.isVerified = false,
  });

  /// A helper method to quickly construct dummy user mock profiles for our UI verification
  factory DummyUser.mock(String email, UserRole role, {bool isVerified = false}) {
    switch (role) {
      case UserRole.user:
        return DummyUser(
          id: '1', 
          email: email, 
          displayName: isVerified ? 'Verified Student' : 'Unverified User', 
          role: UserRole.user,
          isVerified: isVerified
        );
      case UserRole.admin:
        return DummyUser(
          id: '2', 
          email: email, 
          displayName: 'System Admin', 
          role: UserRole.admin,
          isVerified: true // Admins are always verified by default
        );
    }
  }
}
