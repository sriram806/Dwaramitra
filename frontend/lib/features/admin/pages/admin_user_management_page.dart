import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/core/widgets/role_based_widget.dart';
import 'package:frontend/core/constants/user_roles.dart';
import 'package:frontend/models/user_model.dart';

class AdminUserManagementPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const AdminUserManagementPage(),
      );

  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> 
    with RoleBasedAccessMixin {
  
  @override
  String get requiredPermission => 'admin_actions';

  List<UserModel> users = [];
  bool isLoading = false;
  String searchQuery = '';
  String selectedRoleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    
    // Simulate loading users from server
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data - in real app, this would come from API
    users = [
      UserModel(
        id: '1',
        email: 'admin@example.com',
        name: 'Admin User',
        token: 'token1',
        isAccountVerified: true,
        role: 'admin',
        designation: 'Admin Staff',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: '2',
        email: 'security@example.com',
        name: 'Security Officer',
        token: 'token2',
        isAccountVerified: true,
        role: 'security officer',
        designation: 'Staff',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: '3',
        email: 'guard@example.com',
        name: 'Gate Guard',
        token: 'token3',
        isAccountVerified: true,
        role: 'guard',
        designation: 'Staff',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: '4',
        email: 'user@example.com',
        name: 'Regular User',
        token: 'token4',
        isAccountVerified: false,
        role: 'user',
        designation: 'Student',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
    ];
    
    setState(() => isLoading = false);
  }

  List<UserModel> get filteredUsers {
    return users.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                           user.email.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesRole = selectedRoleFilter == 'all' || user.role == selectedRoleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthLoggedIn) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!hasAccess(state.user.role)) {
          return buildAccessDeniedWidget();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'User Management',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.deepPurple,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadUsers,
              ),
            ],
          ),
          body: Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.deepPurple.shade50,
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Role Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all'),
                          _buildFilterChip('Admin', 'admin'),
                          _buildFilterChip('Security Officer', 'security officer'),
                          _buildFilterChip('Guard', 'guard'),
                          _buildFilterChip('User', 'user'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Users List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredUsers.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return _buildUserCard(filteredUsers[index]);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedRoleFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => selectedRoleFilter = value);
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.deepPurple.shade100,
        checkmarkColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final roleColor = _getRoleColor(user.role);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withOpacity(0.2),
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              UserRole.fromString(user.role).displayName,
                              style: TextStyle(
                                color: roleColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  user.isAccountVerified ? Icons.verified : Icons.pending,
                  size: 16,
                  color: user.isAccountVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  user.isAccountVerified ? 'Verified' : 'Pending',
                  style: TextStyle(
                    color: user.isAccountVerified ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  'Designation: ${user.designation}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!user.isAccountVerified)
                  TextButton.icon(
                    onPressed: () => _verifyUser(user),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Verify'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => _editUserRole(user),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Role'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _viewUserDetails(user),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (UserRole.fromString(role)) {
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

  void _verifyUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify User'),
        content: Text('Are you sure you want to verify ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = users.indexWhere((u) => u.id == user.id);
                if (index != -1) {
                  users[index] = users[index].copyWith(isAccountVerified: true);
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} has been verified')),
              );
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _editUserRole(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return ListTile(
              title: Text(role.displayName),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  final index = users.indexWhere((u) => u.id == user.id);
                  if (index != -1) {
                    users[index] = users[index].copyWith(role: role.value);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user.name}\'s role updated to ${role.displayName}')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _viewUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Role: ${UserRole.fromString(user.role).displayName}'),
            Text('Designation: ${user.designation}'),
            Text('Verified: ${user.isAccountVerified ? 'Yes' : 'No'}'),
            Text('Joined: ${user.createdAt.toString().split(' ')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
