import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import '../bloc/profile_cubit.dart';
import '../widgets/profile_page_scaffold.dart';
import 'package:frontend/features/support/pages/help_support_page.dart';
import 'package:frontend/core/services/logout_service.dart';
import 'package:frontend/core/widgets/custom_toast.dart';

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
    return ProfilePageScaffold(
      title: 'Settings & Preferences',
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences Section
            _buildSectionTitle('Preferences'),
            const SizedBox(height: AppSpacing.md),
            _buildPreferencesCard(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Support Section
            _buildSectionTitle('Support'),
            const SizedBox(height: AppSpacing.md),
            _buildSupportCard(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Account Section
            _buildSectionTitle('Account'),
            const SizedBox(height: AppSpacing.md),
            _buildAccountCard(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Danger Zone
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(
        color: AppPallete.textPrimary,
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppPallete.cardBackground,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppPallete.borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppPallete.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPreferenceItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage push notifications and alerts',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle notification toggle
                CustomToast.showInfo(
                  context: context,
                  message: 'Notification preferences will be available soon',
                );
              },
            ),
          ),
          const Divider(height: AppSpacing.lg),
          _buildPreferenceItem(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Toggle between light and dark theme',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Handle theme toggle
                CustomToast.showInfo(
                  context: context,
                  message: 'Theme preferences will be available soon',
                );
              },
            ),
          ),
          const Divider(height: AppSpacing.lg),
          _buildPreferenceItem(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'Select your preferred language',
            trailing: const Text(
              'English',
              style: AppTextStyles.body2,
            ),
            onTap: () {
              CustomToast.showInfo(
                context: context,
                message: 'Language options will be available soon',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppPallete.cardBackground,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppPallete.borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppPallete.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => Navigator.push(context, HelpSupportPage.route()),
            iconColor: AppPallete.primaryColor,
          ),
          const Divider(height: AppSpacing.lg),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: _showAboutDialog,
            iconColor: AppPallete.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppPallete.cardBackground,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppPallete.borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppPallete.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildMenuItem(
        icon: Icons.logout,
        title: 'Logout',
        subtitle: 'Sign out of your account',
        onTap: _performLogout,
        iconColor: AppPallete.warningColor,
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppPallete.errorColor.withOpacity(0.05),
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppPallete.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_outlined, color: AppPallete.errorColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Danger Zone',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppPallete.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Once you delete your account, there is no going back. Please be certain.',
            style: AppTextStyles.body2.copyWith(
              color: AppPallete.errorColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isDeleting
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppPallete.errorColor,
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      key: const ValueKey('delete_button'),
                      onPressed: _showDeleteConfirmation,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.errorColor,
                        foregroundColor: Colors.white,
                        padding: AppSpacing.paddingMD,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.radiusMD,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.radiusSM,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppPallete.surfaceColor,
                borderRadius: AppSpacing.radiusSM,
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppPallete.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppPallete.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppPallete.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.radiusSM,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: AppSpacing.radiusSM,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppPallete.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppPallete.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppPallete.textTertiary,
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
      _showToast('Password is required', isError: true);
      return;
    }

    setState(() => _isDeleting = true);

    try {
      await context.read<ProfileCubit>().deleteAccount(password);

      if (!mounted) return;

      _showToast('Account deleted successfully');

      await Future.delayed(const Duration(seconds: 1));
      context.read<AuthCubit>().logout();
    } catch (error) {
      if (!mounted) return;
      _showToast('Failed to delete account: $error', isError: true);
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
  void _showToast(String message, {bool isError = false}) {
    if (isError) {
      CustomToast.showError(
        context: context,
        message: message,
      );
    } else {
      CustomToast.showSuccess(
        context: context,
        message: message,
      );
    }
  }
}
