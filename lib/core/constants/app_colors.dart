import 'package:flutter/material.dart';

/// Centralized color palette for AGRI AI.
/// Uses rich agricultural green tones, earthy accents, and clean whites.
class AppColors {
  AppColors._();

  // Primary Greens
  static const Color primaryGreen = Color(0xFF2E7D32); // Forest/Agricultural Green
  static const Color primaryDark = Color(0xFF1B5E20);  // Deep Crop Green
  static const Color primaryLight = Color(0xFF4CAF50); // Vibrant Sprout Green
  static const Color greenSurface = Color(0xFFE8F5E9); // Pale Mint Green for Cards & Backgrounds
  static const Color greenAccent = Color(0xFF81C784);  // Subtle Green Accents

  // Earth & Harvest Accents
  static const Color earthAmber = Color(0xFFFFA000);   // Mandi / Market Accent
  static const Color harvestGold = Color(0xFFFFB300);  // Crop Ripeness / Warning
  static const Color alertRed = Color(0xFFD32F2F);     // Disease Warning / Error
  static const Color healthyTeal = Color(0xFF00897B);  // 100% Health Score

  // Background & Surface
  static const Color background = Color(0xFFF7FBF7);  // Clean Off-White with green tint
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F1);

  // Text & Neutral Colors
  static const Color textPrimary = Color(0xFF1E2923);  // High contrast charcoal for outdoor sun
  static const Color textSecondary = Color(0xFF5A6B61);// Subdued slate green
  static const Color textMuted = Color(0xFF8D9E94);    // Placeholder text
  static const Color border = Color(0xFFE0E7E1);       // Clean outline
  static const Color divider = Color(0xFFEEEEEE);
}

