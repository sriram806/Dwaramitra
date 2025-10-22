import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_cubit.dart';
import 'edit_profile_page.dart';
import 'overview_page.dart';
import 'change_password_page.dart';
import 'settings_page.dart';
import 'package:frontend/features/support/pages/help_support_page.dart';
import '../widgets/profile_loading_view.dart';
import '../widgets/profile_error_view.dart';
import '../widgets/modern_profile_header.dart';
import '../widgets/profile_insights_card.dart';
import '../widgets/profile_quick_actions.dart';
import '../widgets/profile_action_button_modern.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_page_scaffold.dart';
import 'package:frontend/core/services/logout_service.dart';
import 'package:frontend/core/widgets/custom_toast.dart';

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
            CustomToast.showError(
              context: context,
              message: state.message,
            );
          } else if (state is ProfileUpdated) {
            CustomToast.showSuccess(
              context: context,
              message: 'Profile updated successfully',
            );
          } else if (state is ProfilePasswordChanged) {
            CustomToast.showSuccess(
              context: context,
              message: 'Password changed successfully',
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

            final user = state is ProfileLoaded ? state.profile : null;

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
            user: user, // Pass the full user object for completion calculation
            actionButtons: [
              ModernActionButton(
                icon: Icons.edit,
                label: 'EDIT PROFILE',
                onTap: () => _navigateToEditProfile(user),
                backgroundColor: Colors.orange,
              ),
            ],
          ),
          
          // Profile Insights Card
          ProfileInsightsCard(user: user),
          
          // Quick actions for profile completion
          ProfileQuickActions(
            user: user,
            onEditProfile: () => _navigateToEditProfile(user),
            onChangePassword: () => _navigateToChangePassword(),
            onViewOverview: () => _navigateToOverview(user),
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
