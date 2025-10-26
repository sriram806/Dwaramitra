import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class AppTheme {
  static OutlineInputBorder _border([Color color = AppPallete.borderColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1.5,
        ),
        borderRadius: AppSpacing.radiusMD,
      );

  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.whiteColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppPallete.textPrimary),
      titleTextStyle: TextStyle(
        color: AppPallete.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.heading1,
      headlineMedium: AppTextStyles.heading2,
      headlineSmall: AppTextStyles.heading3,
      titleLarge: AppTextStyles.subtitle1,
      titleMedium: AppTextStyles.subtitle2,
      bodyLarge: AppTextStyles.body1,
      bodyMedium: AppTextStyles.body2,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.button,
    ).apply(
      bodyColor: AppPallete.textPrimary,
      displayColor: AppPallete.textPrimary,
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: AppPallete.cardBackground,
      elevation: 0,
      shadowColor: AppPallete.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.radiusMD,
        side: const BorderSide(
          color: AppPallete.borderColor,
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.zero,
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppPallete.surfaceColor,
      labelStyle: AppTextStyles.caption.copyWith(
        color: AppPallete.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.radiusSM,
      ),
      side: const BorderSide(
        color: AppPallete.borderColor,
        width: 0.5,
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: AppSpacing.paddingMD,
      filled: true,
      fillColor: AppPallete.cardBackground,
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.primaryColor),
      errorBorder: _border(AppPallete.errorColor),
      focusedErrorBorder: _border(AppPallete.errorColor),
      labelStyle: AppTextStyles.body2.copyWith(
        color: AppPallete.textSecondary,
      ),
      hintStyle: AppTextStyles.body2.copyWith(
        color: AppPallete.textTertiary,
      ),
      errorStyle: AppTextStyles.caption.copyWith(
        color: AppPallete.errorColor,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMD,
        ),
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        elevation: 0,
        shadowColor: AppPallete.shadowMedium,
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppPallete.primaryColor,
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPallete.primaryColor,
        side: const BorderSide(
          color: AppPallete.borderColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMD,
        ),
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    ),
    
    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: AppSpacing.horizontalMD,
      minVerticalPadding: AppSpacing.sm,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.radiusMD,
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppPallete.dividerColor,
      thickness: 1,
      space: 1,
    ),
  );
}
