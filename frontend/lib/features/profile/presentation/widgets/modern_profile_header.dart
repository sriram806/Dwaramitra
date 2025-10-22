import 'package:flutter/material.dart';

class ModernProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String email;
  final VoidCallback? onAvatarTap;
  final List<Widget>? actionButtons;
  final dynamic user; // Add user object to calculate completion

  const ModernProfileHeader({
    super.key,
    this.avatarUrl,
    required this.name,
    required this.email,
    this.onAvatarTap,
    this.actionButtons,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final completionPercentage = _calculateProfileCompletion();
    
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
              // Profile completion indicator
              if (completionPercentage < 100)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getCompletionColor(completionPercentage),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '${completionPercentage.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
          
          // Profile completion bar (only show if not 100%)
          if (completionPercentage < 100) ...[
            const SizedBox(height: 16),
            _buildCompletionBar(completionPercentage),
          ],
          
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

  Widget _buildCompletionBar(double percentage) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completion',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: _getCompletionColor(percentage),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: _getCompletionColor(percentage),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateProfileCompletion() {
    if (user == null) return 0.0;
    
    int completedFields = 0;
    const int totalFields = 8;
    
    // Check required fields
    if (user.name?.isNotEmpty == true) completedFields++;
    if (user.email?.isNotEmpty == true) completedFields++;
    
    // Check optional fields
    if (user.phone?.isNotEmpty == true) completedFields++;
    if (user.universityId?.isNotEmpty == true) completedFields++;
    if (user.department?.isNotEmpty == true) completedFields++;
    if (user.gender?.isNotEmpty == true) completedFields++;
    if (user.designation?.isNotEmpty == true) completedFields++;
    if (user.avatar?.url?.isNotEmpty == true) completedFields++;
    
    return (completedFields / totalFields) * 100;
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
