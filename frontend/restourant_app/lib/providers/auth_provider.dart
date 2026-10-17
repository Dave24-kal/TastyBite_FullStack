import 'package:flutter/foundation.dart';

import '../core/services/authentication_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;

  Future<bool> register({
  required String fullName,
  required String phone,
  required String email,
  required String password,
}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    await _authService.register(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
    );

    final signInSuccess = await signIn(
      email: email,
      password: password,
    );

    if (!signInSuccess) {
      return false;
    }

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

final userLoaded = await loadCurrentUser();

if (!userLoaded) {
  await _authService.signOut();
  _currentUser = null;
  _isLoading = false;
  notifyListeners();
  return false;
}

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
  Future<bool> loadCurrentUser() async {
  _errorMessage = null;
  notifyListeners();

  try {
    final user = await _authService.getCurrentUser();

    _currentUser = user;

    notifyListeners();

    return true;
  } on AuthException catch (e) {
    _currentUser = null;
    _errorMessage = _getAuthErrorMessage(e);

    notifyListeners();

    return false;
  } catch (e) {
    _currentUser = null;
    _errorMessage = 'Unable to load your account. Please try again.';

    notifyListeners();

    return false;
  }
}
Future<void> signOut() async {
  await _authService.signOut();

  _currentUser = null;
  _errorMessage = null;

  notifyListeners();
}

  String _getAuthErrorMessage(AuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'An account already exists with this email.';

    case 'phone-already-in-use':
      return 'This phone number is already registered.';

    case 'account-already-exists':
      return 'An account already exists with these details.';

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

    case 'invalid-credentials':
      return 'Incorrect email or password.';

    case 'invalid-data':
      return 'Please check your email and password.';

    case 'server-error':
      return 'The server encountered a problem. Please try again.';

    case 'not-authenticated':
      return 'Please sign in to continue.';

    case 'session-expired':
      return 'Your session has expired. Please sign in again.';

    case 'invalid-server-response':
      return 'The server returned an invalid response.';

    default:
      return 'Unable to create your account. Please try again.';
  }
}
}
