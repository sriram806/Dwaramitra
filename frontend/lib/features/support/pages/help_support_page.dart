import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpSupportPage extends StatelessWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const HelpSupportPage(),
      );

  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpSection(
            'Frequently Asked Questions',
            Icons.help_outline,
            [
              _buildFAQItem(
                'How do I add a vehicle?',
                'Go to the home page and tap the "Add Vehicle" button. Fill in the required information including license plate, owner details, and vehicle type.',
              ),
              _buildFAQItem(
                'How do I change my password?',
                'Go to Profile > Change Password. Enter your current password and set a new one.',
              ),
              _buildFAQItem(
                'What are the different user roles?',
                'The system has User, Guard, Security Officer, and Admin roles, each with different permissions and access levels.',
              ),
              _buildFAQItem(
                'How do I update my profile information?',
                'Go to Profile > Edit Profile to update your personal information, contact details, and profile picture.',
              ),
              _buildFAQItem(
                'How do I mark a vehicle as exited?',
                'Guards and security officers can mark vehicles as exited from the vehicle management page or home screen.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildHelpSection(
            'Contact Support',
            Icons.support_agent,
            [
              _buildContactItem(
                'Email Support',
                'support@vehiclemanager.com',
                Icons.email,
                () => _launchEmail(context, 'support@vehiclemanager.com'),
              ),
              _buildContactItem(
                'Phone Support',
                '+1 (555) 123-4567',
                Icons.phone,
                () => _launchPhone(context, '+91-6300-146756'),
              ),
              _buildContactItem(
                'Emergency Contact',
                '+1 (555) 911-0000',
                Icons.emergency,
                () => _launchPhone(context, '+91-9876-543210'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildHelpSection(
            'Quick Actions',
            Icons.flash_on,
            [
              _buildActionItem(
                'Report a Bug',
                'Found an issue? Let us know so we can fix it.',
                Icons.bug_report,
                Colors.red,
                () => _showBugReportDialog(context),
              ),
              _buildActionItem(
                'Feature Request',
                'Have an idea for a new feature? Share it with us!',
                Icons.lightbulb_outline,
                Colors.orange,
                () => _showFeatureRequestDialog(context),
              ),
              _buildActionItem(
                'User Guide',
                'Learn how to use all features of the app.',
                Icons.menu_book,
                Colors.blue,
                () => _showUserGuide(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildHelpSection(
            'System Information',
            Icons.info_outline,
            [
              _buildInfoItem('App Version', '1.0.0'),
              _buildInfoItem('Last Updated', 'October 2025'),
              _buildInfoItem('Platform', 'Flutter'),
              _buildInfoItem('Support Level', 'Enterprise'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(String title, String value, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.green, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(value),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildActionItem(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _launchEmail(BuildContext context, String email) {
    Clipboard.setData(ClipboardData(text: email));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email copied to clipboard: $email'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _launchPhone(BuildContext context, String phone) {
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phone number copied to clipboard: $phone'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please describe the bug you encountered:'),
            SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the issue...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showFeatureRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature Request'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What feature would you like to see?'),
            SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe your idea...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature request submitted. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showUserGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Guide'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Getting Started:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Complete your profile information'),
              Text('2. Add vehicles to the system'),
              Text('3. Use quick actions for daily tasks'),
              SizedBox(height: 12),
              Text(
                'Key Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Vehicle management and tracking'),
              Text('• Role-based access control'),
              Text('• Real-time parking status'),
              Text('• Profile management'),
              SizedBox(height: 12),
              Text(
                'Need more help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Contact support for detailed assistance.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
