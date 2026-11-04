import 'package:flutter/material.dart';

enum AdminSection {
  overview,
  userVerification,
  marketplaceModeration,
  liveDispatch,
  mandiOutbreaks,
  systemSettings;

  String get title {
    switch (this) {
      case AdminSection.overview:
        return 'Overview & Analytics';
      case AdminSection.userVerification:
        return 'Farmer & Fleet Verification';
      case AdminSection.marketplaceModeration:
        return 'Marketplace Moderation';
      case AdminSection.liveDispatch:
        return 'Live Dispatch & Logistics';
      case AdminSection.mandiOutbreaks:
        return 'Mandi Rates & Outbreaks';
      case AdminSection.systemSettings:
        return 'System & Roles Config';
    }
  }

  IconData get icon {
    switch (this) {
      case AdminSection.overview:
        return Icons.dashboard_rounded;
      case AdminSection.userVerification:
        return Icons.verified_user_rounded;
      case AdminSection.marketplaceModeration:
        return Icons.storefront_rounded;
      case AdminSection.liveDispatch:
        return Icons.local_shipping_rounded;
      case AdminSection.mandiOutbreaks:
        return Icons.insights_rounded;
      case AdminSection.systemSettings:
        return Icons.tune_rounded;
    }
  }

  String? get badgeText {
    switch (this) {
      case AdminSection.userVerification:
        return '4 New';
      case AdminSection.liveDispatch:
        return 'LIVE';
      default:
        return null;
    }
  }
}

