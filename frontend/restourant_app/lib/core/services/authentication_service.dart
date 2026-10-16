import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class AuthException implements Exception {
  final String code;

  AuthException(this.code);
}

class AuthenticationService {
  final FlutterSecureStorage _secureStorage =
    const FlutterSecureStorage();
  
  Future<String?> getAccessToken() async {
  return await _secureStorage.read(
    key: 'access_token',
  );
}
Future<Map<String, dynamic>> getCurrentUser() async {
  final accessToken = await getAccessToken();

  if (accessToken == null || accessToken.isEmpty) {
    throw AuthException('not-authenticated');
  }

  final url = Uri.parse(
    '${ApiConfig.baseUrl}/auth/me',
  );

  try {
    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    debugPrint(
      'Get current user response: ${response.statusCode}',
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData is Map<String, dynamic>) {
        return responseData;
      }

      throw AuthException('invalid-server-response');
    }

    if (response.statusCode == 401) {
      await _secureStorage.delete(key: 'access_token');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth_signed_in', false);
      await prefs.remove('auth_current_email');

      throw AuthException('session-expired');
    }

    throw AuthException('server-error');
  } on AuthException {
    rethrow;
  } on TimeoutException {
    debugPrint('Get current user request timed out.');
    throw AuthException('network-request-failed');
  } catch (e) {
    debugPrint('Get current user request failed: $e');
    throw AuthException('network-request-failed');
  }
}

  Future<void> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/auth/register',
    );

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'full_name': fullName.trim(),
              'phone': phone.trim(),
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
        'Registration response: ${response.statusCode}',
      );

      if (response.statusCode == 201) {
        return;
      }

      if (response.statusCode == 409) {
  final responseData = jsonDecode(response.body);

  final message = responseData['detail']?.toString() ?? '';

  if (message.toLowerCase().contains('phone')) {
    throw AuthException('phone-already-in-use');
  }

  if (message.toLowerCase().contains('email')) {
    throw AuthException('email-already-in-use');
  }

  throw AuthException('account-already-exists');
}

      if (response.statusCode == 422) {
        throw AuthException('invalid-data');
      }

      throw AuthException('server-error');
    } on AuthException {
      rethrow;
    } on TimeoutException {
      debugPrint('Registration request timed out.');
      throw AuthException('network-request-failed');
    } catch (e) {
      debugPrint('Registration request failed: $e');
      throw AuthException('network-request-failed');
    }
  }

  Future<void> signIn({
  required String email,
  required String password,
}) async {
  final url = Uri.parse(
    '${ApiConfig.baseUrl}/auth/login',
  );

  try {
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email.trim().toLowerCase(),
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    debugPrint(
      'Login response: ${response.statusCode}',
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      final accessToken = responseData['access_token'];

      if (accessToken is! String || accessToken.isEmpty) {
        throw AuthException('invalid-server-response');
      }

      final userData = responseData['user'];

      if (userData is! Map<String, dynamic>) {
        throw AuthException('invalid-server-response');
      }

      final loggedInEmail =
          userData['email']?.toString() ??
          email.trim().toLowerCase();

      // Save the JWT securely.
      await _secureStorage.write(
        key: 'access_token',
        value: accessToken,
      );

      // Preserve the existing login-state information.
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('auth_signed_in', true);

      await prefs.setString(
        'auth_current_email',
        loggedInEmail,
      );

      return;
    }

    if (response.statusCode == 401) {
      throw AuthException('invalid-credentials');
    }

    if (response.statusCode == 422) {
      throw AuthException('invalid-data');
    }

    throw AuthException('server-error');
  } on AuthException {
    rethrow;
  } on TimeoutException {
    debugPrint('Login request timed out.');
    throw AuthException('network-request-failed');
  } catch (e) {
    debugPrint('Login request failed: $e');
    throw AuthException('network-request-failed');
  }
}
     
 Future<void> signOut() async {
  // Remove the JWT from secure storage.
  await _secureStorage.delete(
    key: 'access_token',
  );

  // Clear the existing login-state information.
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool('auth_signed_in', false);

  await prefs.remove('auth_current_email');
}

  Future<void> resetPassword({
    required String email,
  }) async {
    throw AuthException('password-reset-not-connected');
  }

  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('auth_signed_in') ?? false;
  }

  Future<String?> get currentEmail async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('auth_current_email');
  }
}