import 'package:flutter/material.dart';

/// Centralized color palette for the entire application.
///
/// All colors are defined as static constants to ensure consistency
/// across the app and comply with the Open/Closed Principle —
/// extend palette without modifying existing references.
class AppColors {
  AppColors._();

  // ─── Primary ────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D1);

  // ─── Secondary ──────────────────────────────────────────────
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryLight = Color(0xFFFF94A8);
  static const Color secondaryDark = Color(0xFFD14A63);

  // ─── Background ─────────────────────────────────────────────
  static const Color background = Color(0xFFF5F5FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F5);

  // ─── Text ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textHint = Color(0xFF9E9EB8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Status ─────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // ─── Neutral ────────────────────────────────────────────────
  static const Color divider = Color(0xFFE0E0E8);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);

  // ─── Gradients ──────────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
  ];

  static const List<Color> warmGradient = [
    Color(0xFFFF6584),
    Color(0xFFFF9A76),
  ];

  static const List<Color> coolGradient = [
    Color(0xFF6C63FF),
    Color(0xFF48C6EF),
  ];
}
