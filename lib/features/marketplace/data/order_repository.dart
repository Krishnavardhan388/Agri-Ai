import '../../../core/services/api_client.dart';
import '../domain/order_model.dart';

class OrderRepository {
  final ApiClient _apiClient;

  final List<OrderModel> _localOrders = [
    OrderModel(
      id: 'AGRI-1092',
      customerId: 'user-customer-priya',
      customerName: 'Priya Sharma',
      customerPhone: '+91 98765 12345',
      deliveryAddress: 'Flat 402, Green Meadows, Hanamkonda',
      farmerId: 'user-farmer-ramesh',
      farmerName: 'Ramesh Farm, Warangal',
      items: const [
        OrderItemSummary(
          productId: 'PROD-101',
          productTitle: 'Fresh Organic Tomatoes',
          quantityKg: 5.0,
          pricePerKg: 35.0,
          totalPrice: 175.0,
        ),
      ],
      subtotal: 175.0,
      discount: 25.0,
      deliveryFee: 40.0,
      totalAmount: 190.0,
      paymentMethod: 'Razorpay UPI (Google Pay)',
      paymentId: 'pay_live_49921',
      status: OrderStatus.inTransit,
      deliveryOtp: '4821',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    OrderModel(
      id: 'AGRI-1088',
      customerId: 'cust-anand',
      customerName: 'Anand Rao',
      customerPhone: '+91 98765 99999',
      deliveryAddress: 'Subedari, Kazipet (6 km)',
      farmerId: 'user-farmer-ramesh',
      farmerName: 'Ramesh Farm, Warangal',
      items: const [
        OrderItemSummary(
          productId: 'PROD-102',
          productTitle: 'Sona Masoori Raw Rice',
          quantityKg: 50.0,
          pricePerKg: 55.0,
          totalPrice: 2750.0,
        ),
      ],
      subtotal: 2750.0,
      discount: 300.0,
      deliveryFee: 60.0,
      totalAmount: 2510.0,
      paymentMethod: 'Razorpay UPI (PhonePe)',
      paymentId: 'pay_live_48122',
      status: OrderStatus.accepted,
      deliveryOtp: '7192',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  OrderRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  OrderModel _fromApiMap(Map<String, dynamic> map) {
    OrderStatus parsedStatus = OrderStatus.inTransit;
    try {
      parsedStatus = OrderStatus.values.byName(map['status']?.toString() ?? 'inTransit');
    } catch (_) {
      parsedStatus = OrderStatus.inTransit;
    }

    final qty = (map['quantity_kg'] as num?)?.toDouble() ?? 1.0;
    final total = (map['total_amount'] as num?)?.toDouble() ?? 0.0;
    final pricePerKg = qty > 0 ? total / qty : total;

    return OrderModel(
      id: map['id']?.toString() ?? 'AGRI-NEW',
      customerId: map['customer_id']?.toString() ?? 'cust-current',
      customerName: map['buyer_name']?.toString() ?? 'Verified Buyer',
      customerPhone: map['buyer_phone']?.toString() ?? '',
      deliveryAddress: map['delivery_address']?.toString() ?? '',
      farmerId: map['farmer_id']?.toString() ?? 'user-farmer-ramesh',
      farmerName: map['farmer_name']?.toString() ?? 'Partner Farm',
      items: [
        OrderItemSummary(
          productId: map['product_id']?.toString() ?? '',
          productTitle: map['product_name']?.toString() ?? 'Farm Produce',
          quantityKg: qty,
          pricePerKg: pricePerKg,
          totalPrice: total,
        ),
      ],
      subtotal: total,
      discount: 0.0,
      deliveryFee: 40.0,
      totalAmount: total,
      paymentMethod: map['payment_method']?.toString() ?? 'Razorpay UPI',
      paymentId: map['payment_id']?.toString() ?? 'pay_verified',
      status: parsedStatus,
      deliveryOtp: map['delivery_otp']?.toString() ?? '1234',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    _localOrders.insert(0, order);

    try {
      final firstItem = order.items.first;
      final resp = await _apiClient.post(
        '/api/v1/orders/create',
        body: {
          'product_id': firstItem.productId,
          'quantity_kg': firstItem.quantityKg,
          'buyer_name': order.customerName,
          'buyer_phone': order.customerPhone,
          'delivery_address': order.deliveryAddress,
          'customer_id': order.customerId,
          'payment_method': order.paymentMethod,
          'payment_id': order.paymentId,
          'total_amount_override': order.totalAmount,
        },
      );
      if (resp is Map<String, dynamic>) {
        final serverOrder = _fromApiMap(resp);
        _localOrders[0] = serverOrder;
        return serverOrder;
      }
    } catch (_) {}

    return order;
  }

  Future<List<OrderModel>> getOrdersForCustomer(String customerId) async {
    try {
      final resp = await _apiClient.get('/api/v1/orders');
      if (resp is List) {
        return resp
            .whereType<Map>()
            .map((e) => _fromApiMap(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}

    return _localOrders;
  }

  Future<List<OrderModel>> getOrdersForFarmer(String farmerId) async {
    try {
      final resp = await _apiClient.get('/api/v1/orders');
      if (resp is List) {
        return resp
            .whereType<Map>()
            .map((e) => _fromApiMap(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}

    return _localOrders;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _localOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _localOrders[index] = _localOrders[index].copyWith(status: newStatus);
    }

    try {
      await _apiClient.patch(
        '/api/v1/orders/$orderId/status',
        body: {'status': newStatus.name},
      );
    } catch (_) {}
  }
}
