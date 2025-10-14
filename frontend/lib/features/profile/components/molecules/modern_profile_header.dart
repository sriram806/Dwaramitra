import 'package:flutter/material.dart';

class ModernProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String email;
  final VoidCallback? onAvatarTap;
  final List<Widget>? actionButtons;

  const ModernProfileHeader({
    super.key,
    this.avatarUrl,
    required this.name,
    required this.email,
    this.onAvatarTap,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with status indicator
          Stack(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: avatarUrl?.isNotEmpty == true
                        ? Image.network(
                            avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // User Info
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 1.0,
            ),
          ),
          
          const SizedBox(height: 6),
          
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          
          // Action Buttons
          if (actionButtons != null) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actionButtons!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}