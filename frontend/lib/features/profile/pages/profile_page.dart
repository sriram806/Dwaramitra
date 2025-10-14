import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/profile/cubit/profile_cubit.dart';
import 'package:frontend/features/profile/pages/edit_profile_page.dart';
import 'package:frontend/features/profile/pages/overview_page.dart';
import 'package:frontend/features/profile/pages/change_password_page.dart';
import 'package:frontend/features/profile/pages/settings_page.dart';
import 'package:frontend/features/support/pages/help_support_page.dart';
import 'package:frontend/features/profile/components/atoms/profile_loading_view.dart';
import 'package:frontend/features/profile/components/atoms/profile_error_view.dart';
import 'package:frontend/features/profile/components/molecules/modern_profile_header.dart';
import 'package:frontend/features/profile/components/atoms/profile_action_button_modern.dart';
import 'package:frontend/features/profile/components/atoms/profile_menu_item.dart';
import 'package:frontend/features/profile/components/molecules/profile_page_scaffold.dart';
import 'package:frontend/core/services/logout_service.dart';

class ProfilePage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      );

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: 'Profile',
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfilePasswordChanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const ProfileLoadingView();
            }

            if (state is ProfileError) {
              return ProfileErrorView(
                message: state.message,
                onRetry: () => context.read<ProfileCubit>().loadProfile(),
              );
            }

            final user = state is ProfileLoaded ? state.user : null;

            return user == null
                ? const ProfileLoadingView()
                : _buildModernProfileContent(user);
          },
        ),
      ),
    );
  }

  Widget _buildModernProfileContent(user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Modern Profile Header Component
          ModernProfileHeader(
            avatarUrl: user.avatar?.url,
            name: user.name,
            email: user.email,
            actionButtons: [
              ModernActionButton(
                icon: Icons.edit,
                label: 'EDIT PROFILE',
                onTap: () => _navigateToEditProfile(user),
                backgroundColor: Colors.orange,
              ),
            ],
          ),
          
          // Menu Items using reusable components
          ProfileMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'Manage your preferences',
            onTap: () => _navigateToSettings(),
            iconColor: Colors.blue,
          ),
          
          ProfileMenuItem(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your security',
            onTap: () => _navigateToChangePassword(),
            iconColor: Colors.orange,
          ),
          
          ProfileMenuItem(
            icon: Icons.visibility,
            title: 'Overview',
            subtitle: 'View your information',
            onTap: () => _navigateToOverview(user),
            iconColor: Colors.green,
          ),
          
          ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get assistance',
            onTap: () => Navigator.push(context, HelpSupportPage.route()),
            iconColor: Colors.purple,
          ),
          
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'Log out',
            subtitle: 'Sign out of your account',
            onTap: () => LogoutService.showAdvancedLogoutDialog(context),
            iconColor: Colors.red,
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _navigateToOverview(user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OverviewPage(user: user),
      ),
    );
  }



  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(user: null), // We'll create this
      ),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(), // We'll create this
      ),
    );
  }


  void _navigateToEditProfile(user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user),
      ),
    ).then((_) {
      context.read<ProfileCubit>().refreshProfile();
    });
  }




}