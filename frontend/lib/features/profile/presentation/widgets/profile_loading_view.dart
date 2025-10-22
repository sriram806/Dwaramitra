import 'package:flutter/material.dart';

class ProfileLoadingView extends StatelessWidget {
  const ProfileLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Profile...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
