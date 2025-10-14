import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/widgets/role_based_widget.dart';
import 'package:frontend/core/widgets/user_role_display.dart';
import 'package:frontend/core/constants/user_roles.dart';
import 'package:frontend/features/admin/pages/admin_user_management_page.dart';

class RoleBasedDemoPage extends StatelessWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const RoleBasedDemoPage(),
      );

  const RoleBasedDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Role-Based Access Demo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current User Role Display
            const UserRoleDisplay(showPermissions: true),
            
            const SizedBox(height: 24),
            
            // Role-based Content Sections
            const Text(
              'Role-Based Content',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Admin Only Section
            RoleBasedWidget(
              requiredPermission: 'admin_actions',
              child: _buildFeatureCard(
                title: 'Admin Features',
                subtitle: 'Only admins can see this section',
                icon: Icons.admin_panel_settings,
                color: Colors.red,
                onTap: () => Navigator.push(context, AdminUserManagementPage.route()),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Security Officer and above
            RoleBasedWidget(
              requiredPermission: 'manage_security',
              child: _buildFeatureCard(
                title: 'Security Management',
                subtitle: 'Available to Security Officers and Admins',
                icon: Icons.security,
                color: Colors.orange,
                onTap: () => _showFeatureDemo(context, 'Security Management'),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Guard and above
            RoleBasedWidget(
              requiredPermission: 'manage_vehicles',
              child: _buildFeatureCard(
                title: 'Vehicle Management',
                subtitle: 'Available to Guards, Security Officers, and Admins',
                icon: Icons.directions_car,
                color: Colors.blue,
                onTap: () => _showFeatureDemo(context, 'Vehicle Management'),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Reports (Security Officer and above)
            RoleBasedWidget(
              requiredPermission: 'generate_reports',
              child: _buildFeatureCard(
                title: 'Generate Reports',
                subtitle: 'Available to Security Officers and Admins',
                icon: Icons.analytics,
                color: Colors.green,
                onTap: () => _showFeatureDemo(context, 'Reports Generation'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Role-specific content using ConditionalRoleWidget
            const Text(
              'Role-Specific Content',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            ConditionalRoleWidget(
              roleWidgets: {
                'admin': _buildRoleSpecificContent(
                  'Admin Dashboard',
                  'Complete system control and management',
                  Icons.dashboard,
                  Colors.red,
                ),
                'security officer': _buildRoleSpecificContent(
                  'Security Dashboard', 
                  'Monitor security and manage access control',
                  Icons.security,
                  Colors.orange,
                ),
                'guard': _buildRoleSpecificContent(
                  'Guard Station',
                  'Vehicle entry/exit management and monitoring',
                  Icons.local_police,
                  Colors.blue,
                ),
                'user': _buildRoleSpecificContent(
                  'User Portal',
                  'View your vehicles and visit history',
                  Icons.person,
                  Colors.green,
                ),
              },
            ),
            
            const SizedBox(height: 24),
            
            // Role Information Card
            _buildRoleInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSpecificContent(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleInfoCard() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthLoggedIn) {
          return const SizedBox.shrink();
        }

        final userRole = UserRole.fromString(state.user.role);
        final permissions = RoleBasedAccess.getAvailableActionsForRole(state.user.role);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Role', userRole.displayName),
                _buildInfoRow('Level', '${userRole.level}/4'),
                _buildInfoRow('Permissions', '${permissions.length} granted'),
                const SizedBox(height: 16),
                Text(
                  'Role Hierarchy:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...UserRole.values.reversed.map((role) => _buildHierarchyItem(
                  role,
                  role == userRole,
                )).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildHierarchyItem(UserRole role, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.blue.shade50 : null,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent ? Border.all(color: Colors.blue.shade200) : null,
      ),
      child: Row(
        children: [
          Text('${role.level}. '),
          Text(
            role.displayName,
            style: TextStyle(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? Colors.blue.shade700 : null,
            ),
          ),
          if (isCurrent) ...[
            const Spacer(),
            Icon(Icons.person, color: Colors.blue.shade700, size: 16),
          ],
        ],
      ),
    );
  }

  void _showFeatureDemo(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(featureName),
        content: Text('This is a demo of the $featureName feature.\n\nIn a real app, this would navigate to the actual feature page.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}