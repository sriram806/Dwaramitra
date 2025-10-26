import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../bloc/profile_cubit.dart';
import '../widgets/profile_page_scaffold.dart';
import 'package:frontend/core/widgets/custom_toast.dart';

class ChangePasswordPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const ChangePasswordPage(),
      );

  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: 'Change Password',
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            setState(() => _isLoading = false);
            CustomToast.showError(
              context: context,
              message: state.message,
            );
          } else if (state is ProfilePasswordChanged) {
            setState(() => _isLoading = false);
            CustomToast.showSuccess(
              context: context,
              message: 'Password changed successfully!',
            );
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderCard(),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Form Section
                _buildFormCard(),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Security Tips
                _buildSecurityTips(),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Submit Button
                _buildSubmitButton(),
                
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPallete.primaryColor, AppPallete.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.radiusMD,
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
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppSpacing.radiusMD,
            ),
            child: const Icon(
              Icons.security,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Update Your Password',
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Keep your account secure with a strong password',
            style: AppTextStyles.body2.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
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
          _buildPasswordField(
            label: 'Current Password',
            controller: _currentPasswordController,
            isVisible: _isCurrentPasswordVisible,
            onToggleVisibility: () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Current password is required';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          _buildPasswordField(
            label: 'New Password',
            controller: _newPasswordController,
            isVisible: _isNewPasswordVisible,
            onToggleVisibility: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'New password is required';
              }
              if (value!.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          _buildPasswordField(
            label: 'Confirm New Password',
            controller: _confirmPasswordController,
            isVisible: _isConfirmPasswordVisible,
            onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please confirm your password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppPallete.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppPallete.textSecondary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: AppPallete.textSecondary,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: AppPallete.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: AppSpacing.radiusSM,
              borderSide: BorderSide(color: AppPallete.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusSM,
              borderSide: BorderSide(color: AppPallete.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusSM,
              borderSide: BorderSide(color: AppPallete.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusSM,
              borderSide: BorderSide(color: AppPallete.errorColor),
            ),
            contentPadding: AppSpacing.paddingMD,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTips() {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppPallete.primaryColor.withOpacity(0.05),
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppPallete.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppPallete.primaryColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Password Security Tips',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppPallete.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...['Use a mix of uppercase and lowercase letters', 'Include numbers and special characters', 'Make it at least 8 characters long', 'Avoid common words or personal information']
              .map((tip) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppPallete.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            tip,
                            style: AppTextStyles.caption.copyWith(
                              color: AppPallete.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleChangePassword,
        icon: _isLoading 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.lock_reset),
        label: Text(_isLoading ? 'Updating...' : 'Update Password'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPallete.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusMD,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }



  void _handleChangePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        await context.read<ProfileCubit>().changePassword(
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
            );
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          CustomToast.showError(
            context: context,
            message: 'Failed to change password: $e',
          );
        }
      }
    }
  }
}
