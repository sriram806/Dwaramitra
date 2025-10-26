import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppPallete.textPrimary,
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    height: 1.3,
    color: AppPallete.textPrimary,
  );

  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
    color: AppPallete.textPrimary,
  );

  static const subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
    color: AppPallete.textPrimary,
  );

  static const subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
    color: AppPallete.textPrimary,
  );

  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppPallete.textPrimary,
  );

  static const body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppPallete.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.4,
    color: AppPallete.textSecondary,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Alternative naming for easier access
  static const headingLarge = heading1;
  static const headingMedium = heading2;
  static const headingSmall = heading3;
  static const bodyLarge = body1;
  static const bodyMedium = body2;
  static const bodySmall = caption;
}