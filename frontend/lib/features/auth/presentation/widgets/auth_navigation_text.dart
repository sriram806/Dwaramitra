import 'package:flutter/material.dart';

class AuthNavigationText extends StatelessWidget {
  final String leadingText;
  final String actionText;
  final VoidCallback onTap;
  final Color? actionColor;

  const AuthNavigationText({
    super.key,
    required this.leadingText,
    required this.actionText,
    required this.onTap,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          text: leadingText,
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: actionText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: actionColor ?? Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
