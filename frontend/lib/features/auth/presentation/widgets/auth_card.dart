import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;

  const AuthCard({
    super.key,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
          child,
        ],
      ),
    );
  }
}
