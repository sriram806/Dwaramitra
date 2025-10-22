import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileInsightsCard extends StatelessWidget {
  final dynamic user;

  const ProfileInsightsCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade400,
            Colors.purple.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Profile Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Insights Grid
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.account_circle,
                  title: 'Member Since',
                  value: _getMemberSince(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.verified_user,
                  title: 'Status',
                  value: user.isAccountVerified ? 'Verified' : 'Pending',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.work,
                  title: 'Role',
                  value: _getUserRole(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.schedule,
                  title: 'Last Update',
                  value: _getLastUpdate(),
                ),
              ),
            ],
          ),
          
          // Profile Completion Suggestion
          if (_calculateProfileCompletion() < 100) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.tips_and_updates,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Complete Your Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCompletionSuggestion(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getMemberSince() {
    try {
      if (user.createdAt == null) return 'Unknown';
      DateTime date;
      if (user.createdAt is String) {
        date = DateTime.parse(user.createdAt);
      } else {
        date = user.createdAt;
      }
      return DateFormat('MMM yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getUserRole() {
    return user.role?.toString().toUpperCase() ?? 'USER';
  }

  String _getLastUpdate() {
    try {
      if (user.updatedAt == null) return 'Never';
      DateTime date;
      if (user.updatedAt is String) {
        date = DateTime.parse(user.updatedAt);
      } else {
        date = user.updatedAt;
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 30) {
        return DateFormat('MMM dd').format(date);
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return 'Recently';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  double _calculateProfileCompletion() {
    if (user == null) return 0.0;
    
    int completedFields = 0;
    const int totalFields = 8;
    
    // Check fields
    if (user.name?.isNotEmpty == true) completedFields++;
    if (user.email?.isNotEmpty == true) completedFields++;
    if (user.phone?.isNotEmpty == true) completedFields++;
    if (user.universityId?.isNotEmpty == true) completedFields++;
    if (user.department?.isNotEmpty == true) completedFields++;
    if (user.gender?.isNotEmpty == true) completedFields++;
    if (user.designation?.isNotEmpty == true) completedFields++;
    if (user.avatar?.url?.isNotEmpty == true) completedFields++;
    
    return (completedFields / totalFields) * 100;
  }

  String _getCompletionSuggestion() {
    final completion = _calculateProfileCompletion();
    
    if (completion < 50) {
      return 'Add basic information to get started';
    } else if (completion < 75) {
      return 'Add contact details and department info';
    } else {
      return 'Upload a profile photo to complete';
    }
  }
}