import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to Firebase auth state and mirror it locally
    _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser == null) {
        _user = null;
      } else {
        _user = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          photoUrl: firebaseUser.photoURL,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        );
      }
      notifyListeners();
    });
  }

  // authntification

  Future<bool> signIn({required String email, required String password}) async {
    _begin();
    try {
      await _authService.signInWithEmail(email: email, password: password);
      _end();
      return true;
    } on FirebaseAuthException catch (e) {
      _fail(_messageFor(e.code));
      return false;
    } catch (_) {
      _fail('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _begin();
    try {
      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _end();
      return true;
    } on FirebaseAuthException catch (e) {
      _fail(_messageFor(e.code));
      debugPrint('FirebaseAuthException [register]: ${e.code} – ${e.message}');
      return false;
    } catch (e) {
      _fail('An unexpected error occurred. Please try again.');
      debugPrint('Register error: $e');
      return false;
    }
  }

  Future<void> signOut() => _authService.signOut();

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _begin() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _end() {
    _isLoading = false;
    notifyListeners();
  }

  void _fail(String message) {
    _isLoading = false;
    _error = message;
    notifyListeners();
  }

  String _messageFor(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
