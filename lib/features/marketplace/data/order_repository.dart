import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/order_model.dart';

class OrderRepository {
  FirebaseFirestore? _firestore;

  final List<OrderModel> _localOrders = [
    OrderModel(
      id: 'AGRI-1092',
      customerId: 'cust-priya',
      customerName: 'Priya Sharma',
      customerPhone: '+91 98765 12345',
      deliveryAddress: 'Flat 402, Green Meadows, Hanamkonda',
      farmerId: 'farmer-ramesh',
      farmerName: 'Ramesh Farm, Warangal',
      items: const [
        OrderItemSummary(
          productId: 'prod-tomato-1',
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
      farmerId: 'farmer-ramesh',
      farmerName: 'Ramesh Farm, Warangal',
      items: const [
        OrderItemSummary(
          productId: 'prod-rice-2',
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

  OrderRepository({FirebaseFirestore? firestore}) {
    if (firestore != null) _firestore = firestore;
  }

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore;
    if (FirebaseService.isInitialized) {
      _firestore = FirebaseFirestore.instance;
      return _firestore;
    }
    return null;
  }

  Future<void> createOrder(OrderModel order) async {
    _localOrders.insert(0, order);

    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null) {
      try {
        await fs.collection('orders').doc(order.id).set(order.toMap());
      } catch (_) {}
    }
  }

  Future<List<OrderModel>> getOrdersForCustomer(String customerId) async {
    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null) {
      try {
        final snapshot = await fs
            .collection('orders')
            .where('customerId', isEqualTo: customerId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (_) {}
    }

    return _localOrders;
  }

  Future<List<OrderModel>> getOrdersForFarmer(String farmerId) async {
    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null) {
      try {
        final snapshot = await fs
            .collection('orders')
            .where('farmerId', isEqualTo: farmerId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (_) {}
    }

    return _localOrders;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _localOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _localOrders[index] = _localOrders[index].copyWith(status: newStatus);
    }

    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null) {
      try {
        await fs.collection('orders').doc(orderId).update({'status': newStatus.name});
      } catch (_) {}
    }
  }
}

