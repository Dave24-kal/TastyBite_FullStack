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
      (total, item) {
        final price = (item['price'] as num).toDouble();
        final quantity = item['quantity'] as int;

        return total + price * quantity;
      },
    );
  }

  void addToCart(Map<String, dynamic> meal, int quantity) {
    final mealId = meal['id'];

    final existingIndex = _items.indexWhere(
      (item) => item['id'] == mealId,
    );

    if (existingIndex != -1) {
      final existingItem = _items[existingIndex];

      _items[existingIndex] = {
        ...existingItem,
        'quantity': (existingItem['quantity'] as int) + quantity,
      };
    } else {
      _items.add({
        ...meal,
        'price': (meal['price'] as num).toDouble(),
        'quantity': quantity,
      });
    }

    notifyListeners();
  }

  void removeFromCart(dynamic mealId) {
    _items.removeWhere((item) => item['id'] == mealId);
    notifyListeners();
  }

  void updateQuantity(dynamic mealId, int quantity) {
    if (quantity < 1) return;

    final index = _items.indexWhere((item) => item['id'] == mealId);

    if (index == -1) return;

    _items[index] = {
      ..._items[index],
      'quantity': quantity,
    };

    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}