import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

/// Responsive utility for scaling UI across different screen sizes.
///
/// Calculates a scale factor based on screen width vs. design width (375dp).
/// This ensures consistent visual proportions on phones, tablets, and desktops.
class ResponsiveUtils {
  ResponsiveUtils._();

  static const double _designWidth = 375.0;

  /// Initialize the scale factor. Call once at app startup.
  static void init(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    AppSizes.scale = screenWidth / _designWidth;
  }

  /// Check if the current device is a tablet (width > 600dp).
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 600;
  }

  /// Check if the current device is a desktop (width > 1024dp).
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 1024;
  }

  /// Responsive width: returns a fraction of screen width.
  static double width(BuildContext context, double fraction) {
    return MediaQuery.sizeOf(context).width * fraction;
  }

  /// Responsive height: returns a fraction of screen height.
  static double height(BuildContext context, double fraction) {
    return MediaQuery.sizeOf(context).height * fraction;
  }
}
