import 'package:flutter/material.dart';

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
    final bgColor = backgroundColor ?? Colors.orange;
    final txtColor = textColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : bgColor,
          border: isOutlined ? Border.all(color: bgColor) : null,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isOutlined ? bgColor : txtColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isOutlined ? bgColor : txtColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}