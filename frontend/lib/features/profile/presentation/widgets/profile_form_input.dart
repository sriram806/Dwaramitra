import 'package:flutter/material.dart';

class ProfileFormInput extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final bool isRequired;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;

  const ProfileFormInput({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.isRequired = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText ?? label,
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: Colors.grey.shade600) 
                : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
