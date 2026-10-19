import 'package:flutter/foundation.dart';

import '../core/services/food_service.dart';

class FoodProvider extends ChangeNotifier {
  final FoodService _foodService = FoodService();

  List<Map<String, dynamic>> _foods = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get foods => _foods;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> fetchFoods() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _foods = await _foodService.getFoods();
    } catch (e) {
      _errorMessage = 'Failed to load foods. Please try again.';
      debugPrint('Fetch foods error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}