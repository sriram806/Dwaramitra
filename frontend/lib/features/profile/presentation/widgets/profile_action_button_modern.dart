import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const ModernActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppPallete.primaryColor;
    final txtColor = textColor ?? AppPallete.whiteColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.radiusMD,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : bgColor,
            border: Border.all(
              color: isOutlined ? bgColor : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: AppSpacing.radiusMD,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isOutlined ? bgColor : txtColor,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: isOutlined ? bgColor : txtColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
