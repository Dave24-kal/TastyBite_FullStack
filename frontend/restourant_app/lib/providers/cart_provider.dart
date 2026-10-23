import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  static const String _cartStorageKey = 'tastybite_cart';

  // Save the current cart to local storage.
  Future<void> _saveCart() async {
    final preferences = await SharedPreferences.getInstance();

    final cartJson = jsonEncode(_items);

    await preferences.setString(_cartStorageKey, cartJson);
  }

  // Load previously saved cart data.
  Future<void> loadCart() async {
    final preferences = await SharedPreferences.getInstance();

    final savedCart = preferences.getString(_cartStorageKey);

    if (savedCart == null) {
      return;
    }

    try {
      final decodedCart = jsonDecode(savedCart) as List<dynamic>;

      final loadedItems = decodedCart.map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();

      _items
        ..clear()
        ..addAll(loadedItems);

      notifyListeners();
    } catch (error) {
      // Remove corrupted cart data so it doesn't break future launches.
      await preferences.remove(_cartStorageKey);
      _items.clear();
    }
  }

  // Give other classes read-only access to cart items.
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  // Calculate the total quantity of all food items.
  int get itemCount {
    return _items.fold(
      0,
      (total, item) =>
          total + ((item['quantity'] as num?)?.toInt() ?? 0),
    );
  }

  // Calculate the total price of the cart.
  double get totalPrice {
    return _items.fold(
      0.0,
      (total, item) {
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;

        return total + (price * quantity);
      },
    );
  }

  // Add food to the cart or increase its existing quantity.
  void addToCart({
    required Map<String, dynamic> meal,
    required int quantity,
  }) {
    if (quantity < 1) {
      return;
    }

    final mealId = meal['id'];

    final existingIndex = _items.indexWhere(
      (item) => item['id'] == mealId,
    );

    if (existingIndex != -1) {
      final currentQuantity =
          (_items[existingIndex]['quantity'] as num).toInt();

      _items[existingIndex]['quantity'] =
          currentQuantity + quantity;
    } else {
      _items.add({
        'id': mealId,
        'name': meal['name']?.toString() ?? 'Unnamed food',
        'price': double.tryParse(meal['price'].toString()) ?? 0.0,
        'image_url': meal['image_url']?.toString() ?? '',
        'quantity': quantity,
      });
    }

    _saveCart();
    notifyListeners();
  }

  // Change the quantity of an existing cart item.
  void updateQuantity({
    required dynamic mealId,
    required int quantity,
  }) {
    if (quantity < 1) {
      return;
    }

    final index = _items.indexWhere(
      (item) => item['id'] == mealId,
    );

    if (index == -1) {
      return;
    }

    _items[index]['quantity'] = quantity;

    _saveCart();
    notifyListeners();
  }

  // Remove a food item from the cart.
  void removeFromCart(dynamic mealId) {
    _items.removeWhere(
      (item) => item['id'] == mealId,
    );

    _saveCart();
    notifyListeners();
  }

  // Remove every item from the cart.
  void clearCart() {
    _items.clear();

    _saveCart();
    notifyListeners();
  }
}