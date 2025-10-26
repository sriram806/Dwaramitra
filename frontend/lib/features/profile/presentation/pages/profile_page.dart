import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../bloc/profile_cubit.dart';
import '../../domain/entities/profile_entity.dart';
import 'edit_profile_page.dart';
import 'overview_page.dart';
import 'change_password_page.dart';
import 'settings_page.dart';
import 'package:frontend/features/support/pages/help_support_page.dart';
import '../widgets/profile_loading_view.dart';
import '../widgets/profile_error_view.dart';
import '../widgets/modern_profile_header.dart';
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
  
  // Helper function to convert ProfileEntity to UserModel for UI compatibility
  UserModel _profileEntityToUserModel(ProfileEntity profile) {
    return UserModel(
      id: profile.id,
      email: profile.email,
      name: profile.name,
      token: '', // Token managed separately
      isAccountVerified: profile.isAccountVerified,
      phone: profile.phone,
      gender: profile.gender,
      universityId: profile.universityId,
      department: profile.department,
      designation: profile.designation,
      role: profile.role,
      shift: profile.shift,
      avatar: profile.avatar != null ? Avatar(
        url: profile.avatar!.url,
        publicId: profile.avatar!.publicId,
      ) : null,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }
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

            final profile = state is ProfileLoaded ? state.profile : 
                         state is ProfileUpdated ? state.profile : null;

            return profile == null
                ? const ProfileLoadingView()
                : _buildModernProfileContent(_profileEntityToUserModel(profile));
          },
        ),
      ),
    );
  }

  Widget _buildModernProfileContent(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                label: 'Edit Profile',
                onTap: () => _navigateToEditProfile(user),
                backgroundColor: AppPallete.primaryColor,
              ),
            ],
          ),
          
          // Profile Actions Section
          _buildProfileActionsSection(user),
          
          // Settings Section
          _buildSettingsSection(),
          
          // Support Section
          _buildSupportSection(),
        ],
      ),
    );
  }

  Widget _buildProfileActionsSection(user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
            child: Text(
              'Profile',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppPallete.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          ProfileMenuItem(
            icon: Icons.visibility_outlined,
            title: 'Overview',
            subtitle: 'View your information',
            onTap: () => _navigateToOverview(user),
            iconColor: AppPallete.secondaryColor,
          ),
          
          ProfileMenuItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your security',
            onTap: () => _navigateToChangePassword(),
            iconColor: AppPallete.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
            child: Text(
              'Settings',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppPallete.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Preferences',
            subtitle: 'Manage your settings',
            onTap: () => _navigateToSettings(),
            iconColor: AppPallete.greyColor,
          ),
          
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Log out of your account',
            onTap: () => LogoutService.showAdvancedLogoutDialog(context),
            iconColor: AppPallete.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
            child: Text(
              'Support',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppPallete.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get assistance',
            onTap: () => Navigator.push(context, HelpSupportPage.route()),
            iconColor: AppPallete.accentColor,
          ),
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
