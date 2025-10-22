import 'package:flutter/material.dart';

class AuthTextButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? fontSize;

  const AuthTextButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height = 50,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
