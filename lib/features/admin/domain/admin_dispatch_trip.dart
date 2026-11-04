import 'package:flutter/material.dart';

enum DispatchStatus {
  pendingAssignment,
  pickedUp,
  inTransit,
  delivered,
  disputed;

  String get displayName {
    switch (this) {
      case DispatchStatus.pendingAssignment:
        return 'Pending Driver';
      case DispatchStatus.pickedUp:
        return 'Picked Up from Farm';
      case DispatchStatus.inTransit:
        return 'In Transit to Doorstep';
      case DispatchStatus.delivered:
        return 'Delivered & Verified';
      case DispatchStatus.disputed:
        return 'Disputed / Delayed';
    }
  }

  Color get color {
    switch (this) {
      case DispatchStatus.pendingAssignment:
        return const Color(0xFFFFA000); // Amber
      case DispatchStatus.pickedUp:
        return const Color(0xFF1565C0); // Blue
      case DispatchStatus.inTransit:
        return const Color(0xFF0288D1); // Cyan
      case DispatchStatus.delivered:
        return const Color(0xFF2E7D32); // Green
      case DispatchStatus.disputed:
        return const Color(0xFFD32F2F); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case DispatchStatus.pendingAssignment:
        return Icons.person_search_rounded;
      case DispatchStatus.pickedUp:
        return Icons.inventory_rounded;
      case DispatchStatus.inTransit:
        return Icons.local_shipping_rounded;
      case DispatchStatus.delivered:
        return Icons.task_alt_rounded;
      case DispatchStatus.disputed:
        return Icons.report_problem_rounded;
    }
  }
}

class AdminDispatchTrip {
  final String tripId;
  final String orderId;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String driverVehicle;
  final String farmerName;
  final String farmerLocation;
  final String customerName;
  final String customerAddress;
  final String produceSummary;
  final double totalAmount;
  final String deliveryOtp;
  final double distanceKm;
  final DispatchStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final bool isOtpOverridden;

  const AdminDispatchTrip({
    required this.tripId,
    required this.orderId,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.driverVehicle,
    required this.farmerName,
    required this.farmerLocation,
    required this.customerName,
    required this.customerAddress,
    required this.produceSummary,
    required this.totalAmount,
    required this.deliveryOtp,
    required this.distanceKm,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.isOtpOverridden = false,
  });

  AdminDispatchTrip copyWith({
    String? tripId,
    String? orderId,
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? driverVehicle,
    String? farmerName,
    String? farmerLocation,
    String? customerName,
    String? customerAddress,
    String? produceSummary,
    double? totalAmount,
    String? deliveryOtp,
    double? distanceKm,
    DispatchStatus? status,
    DateTime? createdAt,
    DateTime? deliveredAt,
    bool? isOtpOverridden,
  }) {
    return AdminDispatchTrip(
      tripId: tripId ?? this.tripId,
      orderId: orderId ?? this.orderId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      farmerName: farmerName ?? this.farmerName,
      farmerLocation: farmerLocation ?? this.farmerLocation,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      produceSummary: produceSummary ?? this.produceSummary,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      distanceKm: distanceKm ?? this.distanceKm,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      isOtpOverridden: isOtpOverridden ?? this.isOtpOverridden,
    );
  }
}
