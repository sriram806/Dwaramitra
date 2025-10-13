import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';

class AppTheme {
  static OutlineInputBorder _border([Color color = AppPallete.borderColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      );

  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(color: AppPallete.textColor),
      titleTextStyle: TextStyle(
        color: AppPallete.textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppPallete.textColor,
        fontSize: 16,
      ),
      titleMedium: TextStyle(
        color: AppPallete.textColor,
        fontSize: 14,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppPallete.cardBackground,
      labelStyle: const TextStyle(color: AppPallete.textColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: AppPallete.cardBackground,
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.primaryColor),
      errorBorder: _border(AppPallete.errorColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}
