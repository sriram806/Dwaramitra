import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import '../atoms/profile_info_tile.dart';

class ProfileInfoSection extends StatelessWidget {
  final UserModel user;

  const ProfileInfoSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ProfileInfoTile(
            icon: Icons.person,
            title: 'Full Name',
            value: user.name,
          ),
          ProfileInfoTile(
            icon: Icons.email,
            title: 'Email Address',
            value: user.email,
          ),
          if (user.phone != null && user.phone!.isNotEmpty)
            ProfileInfoTile(
              icon: Icons.phone,
              title: 'Phone Number',
              value: user.phone!,
            ),
          ProfileInfoTile(
            icon: Icons.work,
            title: 'Role',
            value: user.role.isEmpty ? 'Not specified' : user.role,
          ),
          ProfileInfoTile(
            icon: Icons.calendar_today,
            title: 'Member Since',
            value: _formatDate(user.createdAt),
          ),
          ProfileInfoTile(
            icon: Icons.update,
            title: 'Last Updated',
            value: _formatDate(user.updatedAt),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}