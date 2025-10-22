import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/user_roles.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';

class RoleBasedWidget extends StatelessWidget {
  final String requiredPermission;
  final Widget child;
  final Widget? fallback;
  final String? requiredRole;
  final List<String>? allowedRoles;

  const RoleBasedWidget({
    super.key,
    this.requiredPermission = '',
    required this.child,
    this.fallback,
    this.requiredRole,
    this.allowedRoles,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthLoggedIn) {
          return fallback ?? const SizedBox.shrink();
        }

        final userRole = state.user.role;
        bool hasAccess = false;

        // Check by specific role
        if (requiredRole != null) {
          hasAccess = userRole == requiredRole;
        }
        // Check by allowed roles list
        else if (allowedRoles != null) {
          hasAccess = allowedRoles!.contains(userRole);
        }
        // Check by permission
        else if (requiredPermission.isNotEmpty) {
          hasAccess = RoleBasedAccess.hasPermission(userRole, requiredPermission);
        }
        // If no conditions specified, show to all authenticated users
        else {
          hasAccess = true;
        }

        return hasAccess ? child : (fallback ?? const SizedBox.shrink());
      },
    );
  }
}

class ConditionalRoleWidget extends StatelessWidget {
  final Map<String, Widget> roleWidgets;
  final Widget? defaultWidget;

  const ConditionalRoleWidget({
    super.key,
    required this.roleWidgets,
    this.defaultWidget,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthLoggedIn) {
          return defaultWidget ?? const SizedBox.shrink();
        }

        final userRole = state.user.role;
        return roleWidgets[userRole] ?? defaultWidget ?? const SizedBox.shrink();
      },
    );
  }
}

// Helper class for role-based navigation
class RoleBasedNavigation {
  static bool canNavigateToRoute(String userRole, String routeName) {
    final adminRoutes = [
      '/admin/dashboard',
      '/admin/users',
      '/admin/reports',
      '/admin/settings',
    ];

    final securityRoutes = [
      '/security/dashboard',
      '/security/logs',
      '/security/users',
      '/security/reports',
    ];

    final guardRoutes = [
      '/guard/dashboard',
      '/guard/vehicles',
      '/guard/entries',
    ];

    final role = UserRole.fromString(userRole);

    switch (role) {
      case UserRole.admin:
        return true; // Admin can access all routes
      case UserRole.securityOfficer:
        return !adminRoutes.contains(routeName) || securityRoutes.contains(routeName);
      case UserRole.guard:
        return !adminRoutes.contains(routeName) && 
               !securityRoutes.contains(routeName) || 
               guardRoutes.contains(routeName);
      case UserRole.user:
        return !adminRoutes.contains(routeName) && 
               !securityRoutes.contains(routeName) && 
               !guardRoutes.contains(routeName);
    }
  }

  static String getDefaultRouteForRole(String userRole) {
    final role = UserRole.fromString(userRole);
    
    switch (role) {
      case UserRole.admin:
        return '/admin/dashboard';
      case UserRole.securityOfficer:
        return '/security/dashboard';
      case UserRole.guard:
        return '/guard/dashboard';
      case UserRole.user:
        return '/home';
    }
  }
}

// Mixin for pages that require role-based access
mixin RoleBasedAccessMixin<T extends StatefulWidget> on State<T> {
  String get requiredRole => '';
  List<String> get allowedRoles => [];
  String get requiredPermission => '';

  bool hasAccess(String userRole) {
    if (requiredRole.isNotEmpty) {
      return userRole == requiredRole;
    }
    
    if (allowedRoles.isNotEmpty) {
      return allowedRoles.contains(userRole);
    }
    
    if (requiredPermission.isNotEmpty) {
      return RoleBasedAccess.hasPermission(userRole, requiredPermission);
    }
    
    return true;
  }

  Widget buildAccessDeniedWidget() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 80,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You do not have permission to access this page.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
