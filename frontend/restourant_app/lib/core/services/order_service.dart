import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'authentication_service.dart';

class OrderException implements Exception {
  final String message;

  OrderException(this.message);

  @override
  String toString() => message;
}

class OrderService {
  final AuthenticationService _authService =
      AuthenticationService();

  Future<Map<String, dynamic>> createOrder({
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    final accessToken = await _authService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw OrderException(
        'Please sign in before placing an order.',
      );
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/orders/',
    );

    final requestItems = items.map((item) {
      return {
        'food_id': (item['id'] as num).toInt(),
        'quantity': (item['quantity'] as num).toInt(),
      };
    }).toList();

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'customer_name': customerName.trim(),
              'customer_phone': customerPhone.trim(),
              'delivery_address': deliveryAddress.trim(),
              'items': requestItems,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint(
        'Create order response: ${response.statusCode}',
      );

      final dynamic responseData =
          jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (responseData is Map<String, dynamic>) {
          return responseData;
        }

        throw OrderException(
          'The server returned an unexpected response.',
        );
      }

      if (response.statusCode == 401) {
        throw OrderException(
          'Your session has expired. Please sign in again.',
        );
      }

      if (responseData is Map<String, dynamic>) {
        final detail = responseData['detail'];

        if (detail is String) {
          throw OrderException(detail);
        }

        if (detail is List) {
          final messages = detail.map((error) {
            if (error is Map<String, dynamic>) {
              return error['msg']?.toString() ??
                  'Invalid order information';
            }

            return error.toString();
          }).join('\n');

          throw OrderException(messages);
        }
      }

      throw OrderException(
        'Could not place your order. '
        'Server status: ${response.statusCode}.',
      );
    } on OrderException {
      rethrow;
    } on TimeoutException {
      throw OrderException(
        'The request timed out. Please try again.',
      );
    } catch (error) {
      debugPrint('Create order failed: $error');

      throw OrderException(
        'Could not connect to the server. '
        'Please check your connection.',
      );
    }
  }
Future<List<Map<String, dynamic>>> getMyOrders() async {
  final accessToken = await _authService.getAccessToken();

  if (accessToken == null || accessToken.isEmpty) {
    throw OrderException(
      'Please sign in to view your orders.',
    );
  }

  final url = Uri.parse(
    '${ApiConfig.baseUrl}/orders/my-orders',
  );

  try {
    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);

      if (responseData is List) {
        return responseData
            .map(
              (item) => Map<String, dynamic>.from(item as Map),
            )
            .toList();
      }

      throw OrderException(
        'The server returned an unexpected response.',
      );
    }

    if (response.statusCode == 401) {
      throw OrderException(
        'Your session has expired. Please sign in again.',
      );
    }

    final dynamic responseData = jsonDecode(response.body);

    if (responseData is Map<String, dynamic> &&
        responseData['detail'] is String) {
      throw OrderException(responseData['detail'] as String);
    }

    throw OrderException(
      'Could not load your orders. '
      'Server status: ${response.statusCode}.',
    );
  } on OrderException {
    rethrow;
  } on TimeoutException {
    throw OrderException(
      'The request timed out. Please try again.',
    );
  } catch (error) {
    debugPrint('Load orders failed: $error');

    throw OrderException(
      'Could not connect to the server. Please check your connection.',
    );
  }
}
}