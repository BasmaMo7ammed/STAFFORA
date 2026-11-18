
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _service.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';

        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'weak-password':
          return 'Password is too weak.';

        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';

        case 'network-request-failed':
          return 'Check your internet connection.';

        case 'too-many-requests':
          return 'Too many attempts. Try again later.';

        case 'operation-not-allowed':
          return 'Email/Password sign-in is not enabled in Firebase.';

        default:
          return error.message ?? 'Authentication failed.';
      }
    }

    return error.toString();
  }

  // SIGN UP
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    _setLoading(true);

    debugPrint('PROVIDER: Sign up started.');

    try {
      await _service.signUp(
        name: name,
        email: email,
        password: password,
      );

      debugPrint('PROVIDER: Sign up successful.');
      return true;
    } catch (error) {
      debugPrint('PROVIDER: Sign up failed: $error');

      _errorMessage = _getErrorMessage(error);
      return false;
    } finally {
      _setLoading(false);
      debugPrint('PROVIDER: Sign up finished.');
    }
  }

  // LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    _setLoading(true);

    debugPrint('PROVIDER: Login started.');
    debugPrint('PROVIDER: isLoading = $_isLoading');

    try {
      await _service.login(
        email: email,
        password: password,
      );

      debugPrint('PROVIDER: Login successful.');
      return true;
    } catch (error) {
      debugPrint('PROVIDER: Login failed: $error');

      _errorMessage = _getErrorMessage(error);
      return false;
    } finally {
      _setLoading(false);

      debugPrint('PROVIDER: Login finished.');
      debugPrint('PROVIDER: isLoading = $_isLoading');
    }
  }

  // FORGOT PASSWORD
  Future<bool> resetPassword({
    required String email,
  }) async {
    _errorMessage = null;
    _setLoading(true);

    debugPrint('PROVIDER: Password reset started.');

    try {
      await _service.resetPassword(email: email);

      debugPrint('PROVIDER: Password reset successful.');
      return true;
    } catch (error) {
      debugPrint('PROVIDER: Password reset failed: $error');

      _errorMessage = _getErrorMessage(error);
      return false;
    } finally {
      _setLoading(false);
      debugPrint('PROVIDER: Password reset finished.');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await _service.logout();
      debugPrint('PROVIDER: Logout successful.');
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      debugPrint('PROVIDER: Logout failed: $error');
    }

    notifyListeners();
  }
}
