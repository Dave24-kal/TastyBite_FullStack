import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../core/services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final OrderService _orderService = OrderService();
  bool _isSubmitting = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_isSubmitting) {
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  try {
    final cartProvider = context.read<CartProvider>();

    final order = await _orderService.createOrder(
      customerName: _nameController.text,
      customerPhone: _phoneController.text,
      deliveryAddress: _addressController.text,
      items: cartProvider.items,
    );

    if (!mounted) return;

    // Clear the cart only after the backend confirms success.
    cartProvider.clearCart();

    final orderId = order['id'];
    final totalAmount = order['total_amount'];

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 56,
          ),
          title: const Text('Order Placed Successfully!'),
          content: Text(
            'Your order #$orderId has been received.\n\n'
            'Total: ETB $totalAmount',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  } on OrderException catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Something went wrong while placing your order.',
        ),
        backgroundColor: Colors.red,
      ),
    );

    debugPrint('Checkout error: $error');
  } finally {
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text('Your cart is empty.'),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '09XXXXXXXX',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final phone = value?.trim() ?? '';

                          if (!RegExp(
                            r'^(\+251|0)?9\d{8}$',
                          ).hasMatch(phone)) {
                            return 'Enter a valid Ethiopian phone number.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Address',
                          hintText: 'Enter your delivery location',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 5) {
                            return 'Please enter a complete delivery address.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'Order Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      const SizedBox(height: 12),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              for (final item in items)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item['name']} × ${item['quantity']}',
                                        ),
                                      ),
                                      Text(
                                        'ETB ${(((item['price'] as num).toDouble()) * ((item['quantity'] as num).toInt())).toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                ),

                              const Divider(),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'ETB ${cartProvider.totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: _isSubmitting ? null : _placeOrder,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
    ),
    child: _isSubmitting
        ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text('Placing Order...'),
            ],
          )
        : const Text('Place Order'),
  ),
),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
