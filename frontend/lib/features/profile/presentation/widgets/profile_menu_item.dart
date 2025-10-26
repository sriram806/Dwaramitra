import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showArrow;
  final Widget? trailing;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.showArrow = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppPallete.cardBackground,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: AppPallete.borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.radiusMD,
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppPallete.primaryColor).withOpacity(0.1),
                    borderRadius: AppSpacing.radiusSM,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppPallete.primaryColor,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: AppSpacing.md),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppPallete.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppPallete.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Trailing
                if (trailing != null)
                  trailing!
                else if (showArrow)
                  Icon(
                    Icons.chevron_right,
                    color: AppPallete.textTertiary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
