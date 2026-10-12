import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthException implements Exception {
  final String code;

  AuthException(this.code);
}

class AuthenticationService {
  Future<void> register({
    required String fullname,
    required String phone,
    required String email,
    required String password,
  }) async {
    final url= Uri.parse(
      '${APIConfig.baseUrl}/auth/register'
    );
    try{
       final response = await http.post(
        url,
        headers: {
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      );
      if (response.statusCode == 201) {
        return;
      }
      if (response.statusCode == 409) {
        throw AuthException('email-already-in-use');
      }
      if (response.statusCode == 422) {
        throw AuthException('invalid-data');
      }
        throw AuthException('server-error');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('network-request-failed');
    }
  }


       

  Future<void> signIn({
    required String email,
    required String password,
  })async {
    throw AuthException('login-not-connected');
  }
  Future<void> signOut() async {
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