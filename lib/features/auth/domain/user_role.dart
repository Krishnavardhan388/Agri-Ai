import 'package:flutter/material.dart';

enum UserRole {
  farmer,
  customer,
  deliveryPartner;

  String get displayName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer (Kisan)';
      case UserRole.customer:
        return 'Customer (Buyer)';
      case UserRole.deliveryPartner:
        return 'Delivery Partner';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.customer:
        return 'Customer';
      case UserRole.deliveryPartner:
        return 'Delivery';
    }
  }

  String get description {
    switch (this) {
      case UserRole.farmer:
        return 'Diagnose crops with AI, monitor mandi prices, and sell harvest at fair rates.';
      case UserRole.customer:
        return 'Order 100% fresh, organic produce straight from local farmers at transparent prices.';
      case UserRole.deliveryPartner:
        return 'Earn by delivering fresh produce from regional farms to customer doorsteps.';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.farmer:
        return Icons.agriculture_rounded;
      case UserRole.customer:
        return Icons.shopping_basket_rounded;
      case UserRole.deliveryPartner:
        return Icons.two_wheeler_rounded;
    }
  }
}
