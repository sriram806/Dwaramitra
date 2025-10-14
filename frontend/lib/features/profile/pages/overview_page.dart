import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum TrendType { up, down, neutral }

class OverviewPage extends StatelessWidget {
  final dynamic user;

  const OverviewPage({super.key, required this.user});

  static MaterialPageRoute route(dynamic user) => MaterialPageRoute(
        builder: (context) => OverviewPage(user: user),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4285F4),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Overview',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _refreshData(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card with Animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4285F4), Color(0xFF1976D2), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4285F4).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Enhanced Avatar with Animation
                  Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: user.avatar?.url != null
                            ? Image.network(
                                user.avatar!.url!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultAvatar(),
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: user.isAccountVerified ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.isAccountVerified ? Icons.verified : Icons.warning,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.isAccountVerified ? 'Verified Account' : 'Unverified',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account Information Section
            _buildSectionTitle('Account Information'),
            const SizedBox(height: 12),
            
            _buildInfoCard([
              _buildInfoItem('Full Name', user.name, Icons.person_outline),
              _buildInfoItem('Email Address', user.email, Icons.email_outlined),
              _buildInfoItem('Phone', user.phone ?? 'Not provided', Icons.phone_outlined),
              _buildInfoItem('Role', _getUserRole(), Icons.admin_panel_settings_outlined),
              // Show shift information for guards
              if (user.role == 'guard' && user.shift != null)
                _buildInfoItem(
                  'Shift Assignment', 
                  user.shift!, 
                  user.shift == 'Day Shift' ? Icons.wb_sunny : Icons.nightlight_round,
                  valueColor: user.shift == 'Day Shift' ? Colors.orange.shade600 : Colors.indigo.shade600,
                ),
            ]),
            
            const SizedBox(height: 24),
            
            // Account Status Section
            _buildSectionTitle('Account Status'),
            const SizedBox(height: 12),
            
            _buildInfoCard([
              _buildInfoItem(
                'Account Status', 
                user.isAccountVerified ? 'Verified' : 'Unverified', 
                Icons.security_outlined,
                valueColor: user.isAccountVerified ? Colors.green : Colors.orange,
              ),
              _buildInfoItem(
                'Member Since', 
                _formatDate(user.createdAt), 
                Icons.calendar_today_outlined,
              ),
              _buildInfoItem(
                'Last Updated', 
                _formatDate(user.updatedAt), 
                Icons.update_outlined,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Activity Section
            _buildSectionTitle('Activity Summary'),
            const SizedBox(height: 12),
            
            // Enhanced Statistics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildEnhancedStatCard(
                  title: 'Profile Views',
                  value: '127',
                  subtitle: '+12 this week',
                  icon: Icons.visibility_outlined,
                  color: const Color(0xFF4285F4),
                  trend: TrendType.up,
                ),
                _buildEnhancedStatCard(
                  title: 'Last Login',
                  value: 'Today',
                  subtitle: '2 hours ago',
                  icon: Icons.login_outlined,
                  color: const Color(0xFF34A853),
                  trend: TrendType.neutral,
                ),
                _buildEnhancedStatCard(
                  title: 'Tasks Created',
                  value: '23',
                  subtitle: '+3 today',
                  icon: Icons.task_outlined,
                  color: const Color(0xFFFF9800),
                  trend: TrendType.up,
                ),
                _buildEnhancedStatCard(
                  title: 'Active Sessions',
                  value: '1',
                  subtitle: 'Current device',
                  icon: Icons.devices_outlined,
                  color: const Color(0xFF9C27B0),
                  trend: TrendType.neutral,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Enhanced Quick Actions
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.download_outlined,
                    title: 'Export Data',
                    color: const Color(0xFF4285F4),
                    onTap: () => _showExportDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy',
                    color: const Color(0xFF34A853),
                    onTap: () => _showPrivacyDialog(context),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildQuickActionCard(
              icon: Icons.security_outlined,
              title: 'Security Center',
              subtitle: 'Manage passwords and two-factor authentication',
              onTap: () => _showSecurityDialog(context),
            ),
            
            const SizedBox(height: 12),
            
            _buildQuickActionCard(
              icon: Icons.notifications_outlined,
              title: 'Notification Preferences',
              subtitle: 'Control what notifications you receive',
              onTap: () => _showNotificationDialog(context),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4285F4), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required TrendType trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              if (trend != TrendType.neutral)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trend == TrendType.up ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    trend == TrendType.up ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: trend == TrendType.up ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.grey.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getUserRole() {
    // Extract role from user object or return default
    try {
      return user.role ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  String _formatDate(dynamic date) {
    try {
      if (date == null) return 'N/A';
      DateTime parsedDate;
      if (date is String) {
        parsedDate = DateTime.parse(date);
      } else if (date is DateTime) {
        parsedDate = date;
      } else {
        return 'N/A';
      }
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return 'N/A';
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Account Data'),
        content: const Text(
          'This feature allows you to export all your account data. This may take a few minutes to process.',
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
                  content: Text('Export requested. You will receive an email when ready.'),
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text('Privacy settings will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Security Center'),
          ],
        ),
        content: const Text(
          'Manage your account security, including password changes and two-factor authentication. This feature will be available in a future update.',
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

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            const Text('Notifications'),
          ],
        ),
        content: const Text(
          'Control what notifications you receive and how you receive them. This feature will be available in a future update.',
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

  void _refreshData(BuildContext context) {
    // Show refresh animation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Refreshing data...'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF4285F4),
      ),
    );
    
    // Here you could add actual refresh logic if needed
    // For now, it's just a UI feedback
  }
}