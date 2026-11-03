enum OrderStatus {
  pending,
  accepted,
  packed,
  inTransit,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Farmer Accepted';
      case OrderStatus.packed:
        return 'Harvest Packed';
      case OrderStatus.inTransit:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItemSummary {
  final String productId;
  final String productTitle;
  final double quantityKg;
  final double pricePerKg;
  final double totalPrice;

  const OrderItemSummary({
    required this.productId,
    required this.productTitle,
    required this.quantityKg,
    required this.pricePerKg,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'quantityKg': quantityKg,
      'pricePerKg': pricePerKg,
      'totalPrice': totalPrice,
    };
  }

  factory OrderItemSummary.fromMap(Map<String, dynamic> map) {
    return OrderItemSummary(
      productId: map['productId'] ?? '',
      productTitle: map['productTitle'] ?? '',
      quantityKg: (map['quantityKg'] as num?)?.toDouble() ?? 1.0,
      pricePerKg: (map['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String farmerId;
  final String farmerName;
  final List<OrderItemSummary> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double totalAmount;
  final String paymentMethod;
  final String paymentId;
  final OrderStatus status;
  final String deliveryOtp;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.farmerId,
    required this.farmerName,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentId,
    required this.status,
    required this.deliveryOtp,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'status': status.name,
      'deliveryOtp': deliveryOtp,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    OrderStatus parsedStatus = OrderStatus.pending;
    try {
      parsedStatus = OrderStatus.values.byName(map['status'] ?? 'pending');
    } catch (_) {
      parsedStatus = OrderStatus.pending;
    }

    final rawItems = map['items'] as List<dynamic>? ?? [];

    return OrderModel(
      id: docId ?? map['id'] ?? 'ord-${DateTime.now().millisecondsSinceEpoch}',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Customer',
      customerPhone: map['customerPhone'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? 'Standard Delivery Address',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? 'Farmer Producer',
      items: rawItems.map((i) => OrderItemSummary.fromMap(Map<String, dynamic>.from(i))).toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 40.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'Razorpay UPI',
      paymentId: map['paymentId'] ?? 'pay_simulated',
      status: parsedStatus,
      deliveryOtp: map['deliveryOtp'] ?? '4281',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? farmerId,
    String? farmerName,
    List<OrderItemSummary>? items,
    double? subtotal,
    double? discount,
    double? deliveryFee,
    double? totalAmount,
    String? paymentMethod,
    String? paymentId,
    OrderStatus? status,
    String? deliveryOtp,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      status: status ?? this.status,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

