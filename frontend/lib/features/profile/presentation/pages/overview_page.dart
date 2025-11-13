import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/custom_toast.dart';
import 'package:frontend/features/profile/presentation/widgets/profile_page_scaffold.dart';
import 'package:intl/intl.dart';

class OverviewPage extends StatelessWidget {
  final dynamic user;

  const OverviewPage({super.key, required this.user});

  static MaterialPageRoute route(dynamic user) => MaterialPageRoute(
    builder: (context) => OverviewPage(user: user),
  );

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: 'Account Overview',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshData(context),
        ),
      ],
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            _buildProfileCard(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Account Information Section
            _buildSectionTitle('Account Information'),
            const SizedBox(height: AppSpacing.md),
            _buildInfoCard([
              _buildInfoItem('Full Name', user.name, Icons.person_outline),
              _buildInfoItem('Email Address', user.email, Icons.email_outlined),
              _buildInfoItem('Phone', user.phone ?? 'Not provided', Icons.phone_outlined),
              _buildInfoItem('Role', _getUserRole(), Icons.admin_panel_settings_outlined),
              // Show shift information for guards
              if (user.role == 'guard' && user.shift != null)
                _buildInfoItem(
                  'Shift Assignment', 
                  user.shift!, 
                  user.shift == 'Day Shift' ? Icons.wb_sunny : Icons.nightlight_round,
                  valueColor: user.shift == 'Day Shift' ? AppPallete.warningColor : AppPallete.secondaryColor,
                ),
            ]),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Account Status Section
            _buildSectionTitle('Account Status'),
            const SizedBox(height: AppSpacing.md),
            _buildInfoCard([
              _buildInfoItem(
                'Account Status', 
                user.isAccountVerified ? 'Verified' : 'Unverified', 
                Icons.security_outlined,
                valueColor: user.isAccountVerified ? AppPallete.successColor : AppPallete.warningColor,
              ),
              _buildInfoItem(
                'Member Since', 
                _formatDate(user.createdAt), 
                Icons.calendar_today_outlined,
              ),
              _buildInfoItem(
                'Last Updated', 
                _formatDate(user.updatedAt), 
                Icons.update_outlined,
              ),
            ]),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPallete.primaryColor, AppPallete.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: AppPallete.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: user.avatar?.url != null
                  ? Image.network(
                      user.avatar!.url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Text(
            user.name,
            style: AppTextStyles.headingMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xs),
          
          Text(
            user.email,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: user.isAccountVerified ? AppPallete.successColor : AppPallete.warningColor,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isAccountVerified ? Icons.verified : Icons.warning,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  user.isAccountVerified ? 'Verified' : 'Unverified',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPallete.primaryColor, AppPallete.primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildInfoCard(List<Widget> children) {
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
        children: children,
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppPallete.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body1.copyWith(
                    color: valueColor ?? AppPallete.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUserRole() {
    switch (user.role?.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'user':
        return 'Student';
      case 'guard':
        return 'Security Guard';
      default:
        return user.role ?? 'Unknown';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    try {
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _refreshData(BuildContext context) {
    CustomToast.showSuccess(
      message: 'Profile data refreshed',
      context: context,
    );
  }
}