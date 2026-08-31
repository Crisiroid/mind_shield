import 'package:flutter/material.dart';

class AppSizes {
  AppSizes._();

  static double _scale = 1.0;
  static double get scale => _scale;
  static set scale(double value) => _scale = value;

  static double get xs => (4 * _scale).roundToDouble();
  static double get sm => (8 * _scale).roundToDouble();
  static double get md => (16 * _scale).roundToDouble();
  static double get lg => (24 * _scale).roundToDouble();
  static double get xl => (32 * _scale).roundToDouble();
  static double get xxl => (48 * _scale).roundToDouble();

  static double get radiusSm => (8 * _scale).roundToDouble();
  static double get radiusMd => (12 * _scale).roundToDouble();
  static double get radiusLg => (16 * _scale).roundToDouble();
  static double get radiusXl => (24 * _scale).roundToDouble();
  static double get radiusCircular => 999.0;

  static double get iconSm => (16 * _scale).roundToDouble();
  static double get iconMd => (24 * _scale).roundToDouble();
  static double get iconLg => (32 * _scale).roundToDouble();
  static double get iconXl => (48 * _scale).roundToDouble();

  static double get fontXs => (10 * _scale).roundToDouble();
  static double get fontSm => (12 * _scale).roundToDouble();
  static double get fontMd => (14 * _scale).roundToDouble();
  static double get fontLg => (16 * _scale).roundToDouble();
  static double get fontXl => (18 * _scale).roundToDouble();
  static double get fontXxl => (22 * _scale).roundToDouble();
  static double get fontTitle => (26 * _scale).roundToDouble();
  static double get fontHeadline => (32 * _scale).roundToDouble();

  static double get buttonHeight => (48 * _scale).roundToDouble();
  static double get inputHeight => (48 * _scale).roundToDouble();
  static double get appBarHeight => (56 * _scale).roundToDouble();
  static double get bottomNavHeight => (64 * _scale).roundToDouble();

  static EdgeInsets get paddingScreenH => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get paddingScreenV => EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get paddingScreen => EdgeInsets.all(md);
}
