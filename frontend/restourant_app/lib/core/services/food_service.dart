import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class FoodService {
  Future<List<Map<String, dynamic>>> getFoods() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/foods/');

    try {
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      debugPrint('Get foods response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is List) {
          return responseData
              .map((food) => Map<String, dynamic>.from(food as Map))
              .toList();
        }

        throw Exception('Invalid food data received from server.');
      }

      throw Exception('Failed to load foods: ${response.statusCode}');
    } on TimeoutException {
      debugPrint('Get foods request timed out.');
      rethrow;
    } catch (e) {
      debugPrint('Get foods request failed: $e');
      rethrow;
    }
  }
}