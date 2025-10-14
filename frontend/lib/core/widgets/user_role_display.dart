import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/constants/user_roles.dart';

class UserRoleDisplay extends StatelessWidget {
  final bool showPermissions;
  
  const UserRoleDisplay({
    super.key,
    this.showPermissions = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthLoggedIn) {
          return const SizedBox.shrink();
        }

        final user = state.user;
        final userRole = UserRole.fromString(user.role);
        final roleColor = _getRoleColor(userRole);

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getRoleIcon(userRole),
                        color: roleColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              userRole.displayName,
                              style: TextStyle(
                                color: roleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.amber[700],
                      size: 24,
                    ),
                  ],
                ),
                
                if (showPermissions) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Permissions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: RoleBasedAccess.getAvailableActionsForRole(user.role)
                        .map((permission) => _buildPermissionChip(permission))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionChip(String permission) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        _formatPermissionName(permission),
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatPermissionName(String permission) {
    return permission
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.securityOfficer:
        return Colors.orange;
      case UserRole.guard:
        return Colors.blue;
      case UserRole.user:
        return Colors.green;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.securityOfficer:
        return Icons.security;
      case UserRole.guard:
        return Icons.local_police;
      case UserRole.user:
        return Icons.person;
    }
  }
}

class RoleBasedNavigationMenu extends StatelessWidget {
  const RoleBasedNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthLoggedIn) {
          return const SizedBox.shrink();
        }

        final userRole = UserRole.fromString(state.user.role);
        final menuItems = _getMenuItemsForRole(userRole);

        return Column(
          children: menuItems.map((item) => _buildMenuItem(context, item)).toList(),
        );
      },
    );
  }

  List<NavigationMenuItem> _getMenuItemsForRole(UserRole role) {
    List<NavigationMenuItem> items = [
      NavigationMenuItem(
        title: 'Home',
        icon: Icons.home,
        route: '/home',
        permission: '',
      ),
      NavigationMenuItem(
        title: 'Profile',
        icon: Icons.person,
        route: '/profile',
        permission: '',
      ),
    ];

    if (role.canManageVehicles) {
      items.add(NavigationMenuItem(
        title: 'Vehicle Management',
        icon: Icons.directions_car,
        route: '/vehicles',
        permission: 'manage_vehicles',
      ));
    }

    if (role.canManageSecurity) {
      items.add(NavigationMenuItem(
        title: 'Security Dashboard',
        icon: Icons.security,
        route: '/security',
        permission: 'manage_security',
      ));
    }

    if (role.canGenerateReports) {
      items.add(NavigationMenuItem(
        title: 'Reports',
        icon: Icons.analytics,
        route: '/reports',
        permission: 'generate_reports',
      ));
    }

    if (role.canPerformAdminActions) {
      items.add(NavigationMenuItem(
        title: 'Admin Panel',
        icon: Icons.admin_panel_settings,
        route: '/admin',
        permission: 'admin_actions',
      ));
    }

    return items;
  }

  Widget _buildMenuItem(BuildContext context, NavigationMenuItem item) {
    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.title),
      onTap: () {
        // Handle navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to ${item.title}...')),
        );
      },
    );
  }
}

class NavigationMenuItem {
  final String title;
  final IconData icon;
  final String route;
  final String permission;

  NavigationMenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.permission,
  });
}