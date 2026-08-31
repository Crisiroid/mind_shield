import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  static const double _designWidth = 375.0;

  static void init(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    AppSizes.scale = screenWidth / _designWidth;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 600;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 1024;
  }

  static double width(BuildContext context, double fraction) {
    return MediaQuery.sizeOf(context).width * fraction;
  }

  static double height(BuildContext context, double fraction) {
    return MediaQuery.sizeOf(context).height * fraction;
  }
}
