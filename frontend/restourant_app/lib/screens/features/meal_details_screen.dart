import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';

class MealDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> meal;

  const MealDetailsScreen({
    super.key,
    required this.meal,
  });

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  int _quantity = 1;

  double get _mealPrice {
    return double.tryParse(widget.meal['price'].toString()) ?? 0;
  }

  double get _totalPrice {
    return _mealPrice * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final mealName = widget.meal['name']?.toString() ?? 'Meal';
    final description =
        widget.meal['description']?.toString() ??
        'No description available.';

    final imageUrl = widget.meal['image_url']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        title: const Text('Meal Details'),
        backgroundColor: const Color(0xFFF8F8F8),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),

              child: SizedBox(
                width: double.infinity,
                height: 250,

                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white,
                            alignment: Alignment.center,

                            child: const Icon(
                              Icons.restaurant_rounded,
                              size: 80,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.white,
                        alignment: Alignment.center,

                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Meal name
            Text(
              mealName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // Meal price
            Text(
              'ETB ${_mealPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Description heading
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // Meal description
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 28),

            // Quantity selector heading
            const Text(
              'Quantity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // Quantity controls
            Row(
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),

                const SizedBox(width: 20),

                Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(width: 20),

                _buildQuantityButton(
                  icon: Icons.add,
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Total price and Add to Cart button
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      Text(
                        'ETB ${_totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 54,

                    child: ElevatedButton.icon(
                      onPressed: () {
  context.read<CartProvider>().addToCart(
    meal: widget.meal,
    quantity: _quantity,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${widget.meal['name']} added to cart!',
      ),
    ),
  );
},

                      icon: const Icon(Icons.shopping_cart_outlined),

                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0xFFFFE8D9),
      borderRadius: BorderRadius.circular(12),

      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),

        child: SizedBox(
          width: 44,
          height: 44,

          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}