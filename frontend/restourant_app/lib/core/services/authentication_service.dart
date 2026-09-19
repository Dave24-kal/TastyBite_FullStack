import 'package:shared_preferences/shared_preferences.dart';

class AuthException implements Exception {
  final String code;

  AuthException(this.code);
}

class AuthenticationService {
  static const String _emailKey = 'auth_email';
  static const String _passwordKey = 'auth_password';
  static const String _signedInKey = 'auth_signed_in';
  static const String _currentEmailKey = 'auth_current_email';

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingEmail = prefs.getString(_emailKey);

    if (existingEmail == email) {
      throw AuthException('email-already-in-use');
    }

    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_signedInKey, true);
    await prefs.setString(_currentEmailKey, email);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_emailKey);
    final storedPassword = prefs.getString(_passwordKey);

    if (storedEmail == null || storedPassword == null) {
      throw AuthException('user-not-found');
    }

    if (storedEmail != email || storedPassword != password) {
      throw AuthException('wrong-password');
    }

    await prefs.setBool(_signedInKey, true);
    await prefs.setString(_currentEmailKey, email);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, false);
    await prefs.remove(_currentEmailKey);
  }

  Future<void> resetPassword({required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_emailKey);

    if (storedEmail != email) {
      throw AuthException('user-not-found');
    }
  }

  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_signedInKey) ?? false;
  }

  Future<String?> get currentEmail async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentEmailKey);
  }
}
