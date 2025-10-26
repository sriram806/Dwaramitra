import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class ProfileFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;

  const ProfileFormField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text(
            label,
            style: AppTextStyles.subtitle2.copyWith(
              color: AppPallete.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Text Field
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          onTap: onTap,
          readOnly: readOnly,
          style: AppTextStyles.body1.copyWith(
            color: enabled ? AppPallete.textPrimary : AppPallete.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter $label',
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? AppPallete.cardBackground : AppPallete.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AppPallete.borderColor,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AppPallete.borderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AppPallete.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AppPallete.errorColor,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AppPallete.errorColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: BorderSide(
                color: AppPallete.borderColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            contentPadding: AppSpacing.paddingMD,
            hintStyle: AppTextStyles.body1.copyWith(
              color: AppPallete.textTertiary,
            ),
            errorStyle: AppTextStyles.caption.copyWith(
              color: AppPallete.errorColor,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final String? hintText;

  const ProfileDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text(
            label,
            style: AppTextStyles.subtitle2.copyWith(
              color: AppPallete.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Dropdown Field
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: AppTextStyles.body1.copyWith(
            color: AppPallete.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? 'Select $label',
            filled: true,
            fillColor: AppPallete.cardBackground,
            border: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AppPallete.borderColor,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AppPallete.borderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AppPallete.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AppPallete.errorColor,
                width: 1.5,
              ),
            ),
            contentPadding: AppSpacing.paddingMD,
            hintStyle: AppTextStyles.body1.copyWith(
              color: AppPallete.textTertiary,
            ),
            errorStyle: AppTextStyles.caption.copyWith(
              color: AppPallete.errorColor,
            ),
          ),
          dropdownColor: AppPallete.cardBackground,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppPallete.textSecondary,
          ),
        ),
      ],
    );
  }
}