import 'package:flutter/material.dart';

class ProfileQuickActions extends StatelessWidget {
  final dynamic user;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onViewOverview;

  const ProfileQuickActions({
    super.key,
    required this.user,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onViewOverview,
  });

  @override
  Widget build(BuildContext context) {
    final missingFields = _getMissingFields();
    
    if (missingFields.isEmpty) {
      return const SizedBox.shrink(); // Don't show if profile is complete
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.rocket_launch,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Complete Your Profile',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Add these details to improve your experience:',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Missing fields
          ...missingFields.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    field,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
          
          const SizedBox(height: 16),
          
          // Quick action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEditProfile,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Complete Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getMissingFields() {
    final List<String> missing = [];
    
    if (user.phone?.isEmpty ?? true) {
      missing.add('Phone number');
    }
    
    if (user.universityId?.isEmpty ?? true) {
      missing.add('University ID');
    }
    
    if (user.department?.isEmpty ?? true) {
      missing.add('Department');
    }
    
    if (user.gender?.isEmpty ?? true) {
      missing.add('Gender');
    }
    
    if (user.designation?.isEmpty ?? true) {
      missing.add('Designation');
    }
    
    if (user.avatar?.url?.isEmpty ?? true) {
      missing.add('Profile photo');
    }
    
    return missing;
  }
}