enum DeliveryTaskStatus {
  available,
  accepted,
  pickedUp,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case DeliveryTaskStatus.available:
        return 'Available for Pickup';
      case DeliveryTaskStatus.accepted:
        return 'Pickup Pending';
      case DeliveryTaskStatus.pickedUp:
        return 'In Transit';
      case DeliveryTaskStatus.delivered:
        return 'Delivered';
      case DeliveryTaskStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class DeliveryTask {
  final String id;
  final String orderId;
  final String farmName;
  final String farmAddress;
  final double farmLat;
  final double farmLng;
  final String farmPhone;
  final String customerName;
  final String customerAddress;
  final double customerLat;
  final double customerLng;
  final String customerPhone;
  final String cropSummary;
  final double totalWeightKg;
  final double distanceKm;
  final double tripPayout;
  final String requiredOtp;
  final DeliveryTaskStatus status;
  final DateTime createdAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  const DeliveryTask({
    required this.id,
    required this.orderId,
    required this.farmName,
    required this.farmAddress,
    required this.farmLat,
    required this.farmLng,
    required this.farmPhone,
    required this.customerName,
    required this.customerAddress,
    required this.customerLat,
    required this.customerLng,
    required this.customerPhone,
    required this.cropSummary,
    required this.totalWeightKg,
    required this.distanceKm,
    required this.tripPayout,
    required this.requiredOtp,
    required this.status,
    required this.createdAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  DeliveryTask copyWith({
    String? id,
    String? orderId,
    String? farmName,
    String? farmAddress,
    double? farmLat,
    double? farmLng,
    String? farmPhone,
    String? customerName,
    String? customerAddress,
    double? customerLat,
    double? customerLng,
    String? customerPhone,
    String? cropSummary,
    double? totalWeightKg,
    double? distanceKm,
    double? tripPayout,
    String? requiredOtp,
    DeliveryTaskStatus? status,
    DateTime? createdAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) {
    return DeliveryTask(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      farmName: farmName ?? this.farmName,
      farmAddress: farmAddress ?? this.farmAddress,
      farmLat: farmLat ?? this.farmLat,
      farmLng: farmLng ?? this.farmLng,
      farmPhone: farmPhone ?? this.farmPhone,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerLat: customerLat ?? this.customerLat,
      customerLng: customerLng ?? this.customerLng,
      customerPhone: customerPhone ?? this.customerPhone,
      cropSummary: cropSummary ?? this.cropSummary,
      totalWeightKg: totalWeightKg ?? this.totalWeightKg,
      distanceKm: distanceKm ?? this.distanceKm,
      tripPayout: tripPayout ?? this.tripPayout,
      requiredOtp: requiredOtp ?? this.requiredOtp,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'farmName': farmName,
      'farmAddress': farmAddress,
      'farmLat': farmLat,
      'farmLng': farmLng,
      'farmPhone': farmPhone,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerLat': customerLat,
      'customerLng': customerLng,
      'customerPhone': customerPhone,
      'cropSummary': cropSummary,
      'totalWeightKg': totalWeightKg,
      'distanceKm': distanceKm,
      'tripPayout': tripPayout,
      'requiredOtp': requiredOtp,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  factory DeliveryTask.fromMap(Map<String, dynamic> map, [String? docId]) {
    return DeliveryTask(
      id: docId ?? map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      farmName: map['farmName'] ?? '',
      farmAddress: map['farmAddress'] ?? '',
      farmLat: (map['farmLat'] as num?)?.toDouble() ?? 17.9689,
      farmLng: (map['farmLng'] as num?)?.toDouble() ?? 79.5941,
      farmPhone: map['farmPhone'] ?? '',
      customerName: map['customerName'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      customerLat: (map['customerLat'] as num?)?.toDouble() ?? 18.0072,
      customerLng: (map['customerLng'] as num?)?.toDouble() ?? 79.5583,
      customerPhone: map['customerPhone'] ?? '',
      cropSummary: map['cropSummary'] ?? '',
      totalWeightKg: (map['totalWeightKg'] as num?)?.toDouble() ?? 1.0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      tripPayout: (map['tripPayout'] as num?)?.toDouble() ?? 0.0,
      requiredOtp: map['requiredOtp'] ?? '1234',
      status: DeliveryTaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DeliveryTaskStatus.available,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      pickedUpAt: map['pickedUpAt'] != null
          ? DateTime.tryParse(map['pickedUpAt'])
          : null,
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.tryParse(map['deliveredAt'])
          : null,
    );
  }
}

class DeliveryWalletRecord {
  final String id;
  final String title;
  final String? orderId;
  final double amount;
  final DateTime timestamp;
  final bool isCredit;
  final String status;

  const DeliveryWalletRecord({
    required this.id,
    required this.title,
    this.orderId,
    required this.amount,
    required this.timestamp,
    required this.isCredit,
    this.status = 'Completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'orderId': orderId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'isCredit': isCredit,
      'status': status,
    };
  }

  factory DeliveryWalletRecord.fromMap(Map<String, dynamic> map) {
    return DeliveryWalletRecord(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      orderId: map['orderId'],
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isCredit: map['isCredit'] ?? true,
      status: map['status'] ?? 'Completed',
    );
  }
}

