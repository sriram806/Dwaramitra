import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double logoHeight;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo
        Center(
          child: Image.asset(
            "assets/images/logo.png",
            height: logoHeight,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: logoHeight,
                width: logoHeight,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Welcome text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.green],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
