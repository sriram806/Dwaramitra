enum UserRole {
  user('user'),
  guard('guard'),
  securityOfficer('security officer'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return UserRole.user;
      case 'guard':
        return UserRole.guard;
      case 'security officer':
        return UserRole.securityOfficer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.guard:
        return 'Guard';
      case UserRole.securityOfficer:
        return 'Security Officer';
      case UserRole.admin:
        return 'Admin';
    }
  }

  // Role hierarchy levels (higher number = more permissions)
  int get level {
    switch (this) {
      case UserRole.user:
        return 1;
      case UserRole.guard:
        return 2;
      case UserRole.securityOfficer:
        return 3;
      case UserRole.admin:
        return 4;
    }
  }

  // Check if this role has permission to perform admin actions
  bool get canPerformAdminActions => this == UserRole.admin;

  // Check if this role has permission to manage security
  bool get canManageSecurity => level >= UserRole.securityOfficer.level;

  // Check if this role has permission to manage vehicles
  bool get canManageVehicles => level >= UserRole.guard.level;

  // Check if this role has permission to view all users
  bool get canViewAllUsers => level >= UserRole.securityOfficer.level;

  // Check if this role has permission to update user roles
  bool get canUpdateUserRoles => this == UserRole.admin;

  // Check if this role has permission to verify accounts
  bool get canVerifyAccounts => this == UserRole.admin;

  // Check if this role has permission to access admin dashboard
  bool get canAccessAdminDashboard => level >= UserRole.securityOfficer.level;

  // Check if this role can approve/reject vehicle entries
  bool get canApproveVehicleEntries => level >= UserRole.guard.level;

  // Check if this role can generate reports
  bool get canGenerateReports => level >= UserRole.securityOfficer.level;
}

class RoleBasedAccess {
  static bool hasPermission(String userRole, String requiredPermission) {
    final role = UserRole.fromString(userRole);
    
    switch (requiredPermission.toLowerCase()) {
      case 'admin_actions':
        return role.canPerformAdminActions;
      case 'manage_security':
        return role.canManageSecurity;
      case 'manage_vehicles':
        return role.canManageVehicles;
      case 'view_all_users':
        return role.canViewAllUsers;
      case 'update_user_roles':
        return role.canUpdateUserRoles;
      case 'verify_accounts':
        return role.canVerifyAccounts;
      case 'admin_dashboard':
        return role.canAccessAdminDashboard;
      case 'approve_vehicle_entries':
        return role.canApproveVehicleEntries;
      case 'generate_reports':
        return role.canGenerateReports;
      default:
        return false;
    }
  }

  static List<String> getAvailableActionsForRole(String userRole) {
    final role = UserRole.fromString(userRole);
    List<String> actions = ['view_profile', 'edit_profile'];

    if (role.canManageVehicles) {
      actions.addAll(['add_vehicle', 'edit_vehicle', 'delete_vehicle']);
    }

    if (role.canApproveVehicleEntries) {
      actions.addAll(['approve_entry', 'reject_entry']);
    }

    if (role.canViewAllUsers) {
      actions.add('view_all_users');
    }

    if (role.canManageSecurity) {
      actions.addAll(['manage_security', 'view_security_logs']);
    }

    if (role.canGenerateReports) {
      actions.add('generate_reports');
    }

    if (role.canUpdateUserRoles) {
      actions.add('update_user_roles');
    }

    if (role.canVerifyAccounts) {
      actions.add('verify_accounts');
    }

    if (role.canAccessAdminDashboard) {
      actions.add('admin_dashboard');
    }

    return actions;
  }
}
