import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Central state manager for Authentication routing.
/// Controls login states and manages the global user profile via Supabase live streams.
class AuthController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';
  StreamSubscription<AuthState>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  AuthController() {
    _initializeAuthListener();
  }

  /// Automatically binds to Supabase Auth state changes (Login, Logout, Token Refresh).
  void _initializeAuthListener() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedOut || session == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
        await _fetchProfile(session.user.id);
      }
    });
  }

  /// Fetches the extended profile data from the public `profiles` table.
  Future<void> _fetchProfile(String userId) async {
    _setLoading(true);
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
          
      _currentUser = UserModel.fromJson(data);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = "Failed to load user profile: ${e.toString()}";
    } finally {
      _setLoading(false);
      // The listener automatically notifies UI components
      notifyListeners();
    }
  }

  /// Supabase Email/Password Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      _errorMessage = '';
      return true; // _initializeAuthListener handles routing automatically
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supabase Email/Password Signup
  Future<bool> signup(String email, String password, String name) async {
    _setLoading(true);
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      // Attempt to immediately update the new row created by the Postgres Trigger
      // with their full real name, instead of the email-prefix fallback.
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('profiles').update({'display_name': name}).eq('id', user.id);
      }
      
      _errorMessage = '';
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates the current user's profile details both locally and on Supabase.
  Future<void> updateProfile({String? displayName, String? location}) async {
    if (_currentUser == null) return;
    
    // Update local mock state instantly for snappy UI response
    _currentUser = _currentUser!.copyWith(
      displayName: displayName,
      location: location,
    );
    notifyListeners();

    // Push quietly to Supabase
    try {
      await _supabase.from('profiles').update({
        if (displayName != null) 'display_name': displayName,
        if (location != null) 'location': location,
      }).eq('id', _currentUser!.id);
    } catch (e) {
      // Revert logic would go here if needed
    }
  }

  /// Clears the session and tokens
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
