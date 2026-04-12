import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// The AuthController handles the global logic of managing the current user's simulated session.
/// By extending `ChangeNotifier`, we ensure the `MainApp` redraws automatically to `MainView` 
/// or `LoginView` whenever `login()` or `logout()` is called. 
class AuthController extends ChangeNotifier {
  DummyUser? _currentUser;
  
  /// Returns the actively logged in dummy user. Null if not logged in.
  DummyUser? get currentUser => _currentUser;

  /// Returns true if a user is stored in the mocked session.
  bool get isLoggedIn => _currentUser != null;

  /// Simulates a login mechanism checking hardcoded credentials.
  /// Hardcoded Accounts (password can be anything):
  /// admin@boipao.com (Admin)
  /// user@boipao.com (General User -> Unverified)
  /// verified@boipao.com (General User -> Verified)
  bool login(String email, String password) {
    if (email.trim().toLowerCase() == 'admin@boipao.com') {
      _currentUser = DummyUser.mock(email, UserRole.admin);
    } else if (email.trim().toLowerCase() == 'user@boipao.com') {
      _currentUser = DummyUser.mock(email, UserRole.user, isVerified: false);
    } else if (email.trim().toLowerCase() == 'verified@boipao.com') {
      _currentUser = DummyUser.mock(email, UserRole.user, isVerified: true);
    } else {
      return false; // Failed login due to unknown email
    }
    
    notifyListeners(); // Let the UI know to swap pages
    return true; // Success
  }

  /// Clears the mocked session.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
