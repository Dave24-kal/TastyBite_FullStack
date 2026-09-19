import 'package:flutter/foundation.dart';

import '../core/services/authentication_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getAuthErrorMessage(e);
      notifyListeners();

      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();

      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getAuthErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  String _getAuthErrorMessage(AuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Your password is too weak.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
        return 'Incorrect email or password.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'operation-not-allowed':
        return 'Email and password authentication is not enabled.';

      default:
        return 'Unable to create your account. Please try again.';
    }
  }
}
