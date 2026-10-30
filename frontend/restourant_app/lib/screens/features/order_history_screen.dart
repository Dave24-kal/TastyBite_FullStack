import 'package:flutter/material.dart';

import '../../core/services/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() =>
      _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();

  List<Map<String, dynamic>> _orders = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _orderService.getMyOrders();

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } on OrderException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });

      debugPrint('Order history error: $error');
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'Date unavailable';
    }

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year at $hour:$minute';
    } catch (_) {
      return 'Date unavailable';
    }
  }

  String _formatAmount(dynamic value) {
    final amount = double.tryParse(value.toString());

    if (amount == null) {
      return 'Unavailable';
    }

    return amount.toStringAsFixed(2);
  }

  Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'delivered':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    case 'confirmed':
      return Colors.blue;
    case 'preparing':
      return Colors.deepPurple;
    case 'ready':
      return Colors.teal;
    case 'pending':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
        ),
        const Icon(
          Icons.receipt_long_outlined,
          size: 80,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Your orders will appear here.',
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
        ),
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage ?? 'Unable to load your orders.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: _loadOrders,
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'];
    final status = (order['status'] ?? 'unknown').toString();
    final items = order['items'] is List
        ? order['items'] as List
        : <dynamic>[];

    return Card(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.receipt_long,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          'Order #$orderId',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatDate(order['created_at'])),
              const SizedBox(height: 6),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: _statusColor(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ETB ${_formatAmount(order['total_amount'])}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Name: ${order['customer_name'] ?? 'Unavailable'}',
                ),
                Text(
                  'Phone: ${order['customer_phone'] ?? 'Unavailable'}',
                ),
                Text(
                  'Address: ${order['delivery_address'] ?? 'Unavailable'}',
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ordered Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const Text('No item details available.')
                else
                  for (final item in items)
                    if (item is Map)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item['food_name'] ?? 'Unknown food'}'
                                ' × ${item['quantity'] ?? 0}',
                              ),
                            ),
                            Text(
                              'ETB ${_formatAmount(item['unit_price'])}',
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadOrders,
            tooltip: 'Refresh orders',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: _errorMessage != null
                  ? _buildErrorState()
                  : _orders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 16),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(_orders[index]);
                          },
                        ),
            ),
    );
  }
}