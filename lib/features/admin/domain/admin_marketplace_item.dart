import 'package:flutter/material.dart';

enum ProductModerationStatus {
  active,
  priceAlert,
  unlisted,
  outOfStock;

  String get displayName {
    switch (this) {
      case ProductModerationStatus.active:
        return 'Active & Approved';
      case ProductModerationStatus.priceAlert:
        return 'Price Anomaly Alert';
      case ProductModerationStatus.unlisted:
        return 'Unlisted / Paused';
      case ProductModerationStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  Color get color {
    switch (this) {
      case ProductModerationStatus.active:
        return const Color(0xFF2E7D32); // Green
      case ProductModerationStatus.priceAlert:
        return const Color(0xFFD32F2F); // Red
      case ProductModerationStatus.unlisted:
        return const Color(0xFF757575); // Grey
      case ProductModerationStatus.outOfStock:
        return const Color(0xFFFFA000); // Amber
    }
  }

  IconData get icon {
    switch (this) {
      case ProductModerationStatus.active:
        return Icons.check_circle_rounded;
      case ProductModerationStatus.priceAlert:
        return Icons.warning_rounded;
      case ProductModerationStatus.unlisted:
        return Icons.pause_circle_rounded;
      case ProductModerationStatus.outOfStock:
        return Icons.remove_shopping_cart_rounded;
    }
  }
}

class AdminProductItem {
  final String id;
  final String farmerName;
  final String farmerLocation;
  final String title;
  final String category;
  final double pricePerKg;
  final double mandiBenchmarkPerKg;
  final double stockKg;
  final bool isOrganic;
  final ProductModerationStatus status;
  final String? moderationNote;

  const AdminProductItem({
    required this.id,
    required this.farmerName,
    required this.farmerLocation,
    required this.title,
    required this.category,
    required this.pricePerKg,
    required this.mandiBenchmarkPerKg,
    required this.stockKg,
    required this.isOrganic,
    required this.status,
    this.moderationNote,
  });

  double get priceDeviationPercent {
    if (mandiBenchmarkPerKg <= 0) return 0.0;
    return ((pricePerKg - mandiBenchmarkPerKg) / mandiBenchmarkPerKg) * 100.0;
  }

  bool get hasHighDeviation => priceDeviationPercent > 45.0;

  AdminProductItem copyWith({
    String? id,
    String? farmerName,
    String? farmerLocation,
    String? title,
    String? category,
    double? pricePerKg,
    double? mandiBenchmarkPerKg,
    double? stockKg,
    bool? isOrganic,
    ProductModerationStatus? status,
    String? moderationNote,
  }) {
    return AdminProductItem(
      id: id ?? this.id,
      farmerName: farmerName ?? this.farmerName,
      farmerLocation: farmerLocation ?? this.farmerLocation,
      title: title ?? this.title,
      category: category ?? this.category,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      mandiBenchmarkPerKg: mandiBenchmarkPerKg ?? this.mandiBenchmarkPerKg,
      stockKg: stockKg ?? this.stockKg,
      isOrganic: isOrganic ?? this.isOrganic,
      status: status ?? this.status,
      moderationNote: moderationNote ?? this.moderationNote,
    );
  }
}
