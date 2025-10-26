import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class ModernProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String email;
  final VoidCallback? onAvatarTap;
  final List<Widget>? actionButtons;
  final dynamic user; // Add user object to calculate completion

  const ModernProfileHeader({
    super.key,
    this.avatarUrl,
    required this.name,
    required this.email,
    this.onAvatarTap,
    this.actionButtons,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final completionPercentage = _calculateProfileCompletion();
    
    return Container(
      width: double.infinity,
      margin: AppSpacing.paddingLG.copyWith(bottom: AppSpacing.md),
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: AppPallete.cardBackground,
        borderRadius: AppSpacing.radiusLG,
        border: Border.all(
          color: AppPallete.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Avatar Section
          _buildAvatar(completionPercentage),
          
          const SizedBox(height: AppSpacing.lg),
          
          // User Info Section
          _buildUserInfo(),
          
          // Profile completion indicator (only show if not 100%)
          if (completionPercentage < 100) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildCompletionIndicator(completionPercentage),
          ],
          
          // Action Buttons
          if (actionButtons != null && actionButtons!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(double completionPercentage) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppPallete.borderColor,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: avatarUrl?.isNotEmpty == true
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        
        // Completion indicator badge
        if (completionPercentage < 100)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _getCompletionColor(completionPercentage),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPallete.whiteColor, width: 2),
              ),
              child: Text(
                '${completionPercentage.toInt()}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppPallete.whiteColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          name,
          style: AppTextStyles.heading3.copyWith(
            color: AppPallete.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          email,
          style: AppTextStyles.body2.copyWith(
            color: AppPallete.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompletionIndicator(double percentage) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 16,
              color: AppPallete.textTertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Profile completion',
              style: AppTextStyles.caption.copyWith(
                color: AppPallete.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${percentage.toInt()}%',
              style: AppTextStyles.caption.copyWith(
                color: _getCompletionColor(percentage),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: AppPallete.surfaceColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getCompletionColor(percentage),
          ),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: actionButtons!.map((button) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: actionButtons!.length > 1 ? AppSpacing.xs : 0,
            ),
            child: button,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.primaryColor,
            AppPallete.primaryDark,
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: AppTextStyles.heading2.copyWith(
            color: AppPallete.whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  double _calculateProfileCompletion() {
    if (user == null) return 0.0;
    
    int completedFields = 0;
    const int totalFields = 8;
    
    // Check required fields
    if (user.name?.isNotEmpty == true) completedFields++;
    if (user.email?.isNotEmpty == true) completedFields++;
    
    // Check optional fields
    if (user.phone?.isNotEmpty == true) completedFields++;
    if (user.universityId?.isNotEmpty == true) completedFields++;
    if (user.department?.isNotEmpty == true) completedFields++;
    if (user.gender?.isNotEmpty == true) completedFields++;
    if (user.designation?.isNotEmpty == true) completedFields++;
    if (user.avatar?.url?.isNotEmpty == true) completedFields++;
    
    return (completedFields / totalFields) * 100;
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 80) return AppPallete.successColor;
    if (percentage >= 60) return AppPallete.warningColor;
    return AppPallete.errorColor;
  }
}
