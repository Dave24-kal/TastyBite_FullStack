import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  int get itemCount {
    return _items.fold(
      0,
      (total, item) => total + (item['quantity'] as int),
    );
  }

  double get totalPrice {
    return _items.fold(
      0.0,
      (total, item) =>
          total +
          ((item['price'] as double) * (item['quantity'] as int)),
    );
  }

  void addToCart({
    required Map<String, dynamic> meal,
    required int quantity,
  }) {
    final mealId = meal['id'];

    final existingIndex = _items.indexWhere(
      (item) => item['id'] == mealId,
    );

    if (existingIndex != -1) {
      _items[existingIndex]['quantity'] =
          (_items[existingIndex]['quantity'] as int) + quantity;
    } else {
      _items.add({
        'id': mealId,
        'name': meal['name']?.toString() ?? 'Unnamed food',
        'price': double.tryParse(meal['price'].toString()) ?? 0.0,
        'image_url': meal['image_url']?.toString() ?? '',
        'quantity': quantity,
      });
    }

    notifyListeners();
  }

  void removeFromCart(dynamic mealId) {
    _items.removeWhere((item) => item['id'] == mealId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}