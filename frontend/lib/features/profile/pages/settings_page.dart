import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/profile/cubit/profile_cubit.dart';
import 'package:frontend/features/profile/components/molecules/profile_page_scaffold.dart';
import 'package:frontend/features/profile/components/atoms/profile_menu_item.dart';
import 'package:frontend/features/profile/components/atoms/profile_button.dart';
import 'package:frontend/features/support/pages/help_support_page.dart';
import 'package:frontend/core/services/logout_service.dart';

class SettingsPage extends StatefulWidget {
  final dynamic user;

  const SettingsPage({super.key, required this.user});

  static MaterialPageRoute route(dynamic user) =>
      MaterialPageRoute(builder: (context) => SettingsPage(user: user));

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDeleting = false;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ProfilePageScaffold(
      title: 'Settings',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Help & Support Section
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () => Navigator.push(context, HelpSupportPage.route()),
              iconColor: Colors.blue,
            ),
            
            const SizedBox(height: 16),
            
            // About Section
            ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              onTap: _showAboutDialog,
              iconColor: Colors.green,
            ),
            
            const SizedBox(height: 16),

            // Logout Section
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              onTap: _performLogout,
              iconColor: Colors.orange,
            ),
            
            const SizedBox(height: 32),

            // Danger Zone
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Danger Zone',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Once you delete your account, there is no going back. Please be certain.',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isDeleting
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.red),
                          )
                        : ProfileButton(
                            key: const ValueKey('delete_button'),
                            text: 'Delete Account',
                            onPressed: _showDeleteConfirmation,
                            backgroundColor: Colors.red,
                            icon: Icons.delete_forever,
                            width: double.infinity,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------
  // About Dialog
  // -------------------
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('About Dwaramitra'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚗 Dwaramitra App'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Vehicle Management System'),
            SizedBox(height: 12),
            Text('© 2025 Dwaramitra Team'),
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

  // -------------------
  // Delete Confirmation Dialog
  // -------------------
  void _showDeleteConfirmation() {
    _passwordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Account Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action is irreversible. All your data will be permanently deleted.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please enter your password to confirm:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // -------------------
  // Delete Account Logic
  // -------------------
  Future<void> _deleteAccount() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      _showSnackBar('Password is required', Colors.orange);
      return;
    }

    setState(() => _isDeleting = true);

    try {
      await context.read<ProfileCubit>().deleteAccount(password);

      if (!mounted) return;

      _showSnackBar('Account deleted successfully', Colors.green);

      await Future.delayed(const Duration(seconds: 1));
      context.read<AuthCubit>().logout();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Failed to delete account: $error', Colors.red);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // -------------------
  // Logout Handler
  // -------------------
  void _performLogout() {
    LogoutService.showAdvancedLogoutDialog(context);
  }

  // -------------------
  // Snackbar Helper
  // -------------------
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
