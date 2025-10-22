import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_cubit.dart';
import '../widgets/profile_page_scaffold.dart';
import '../widgets/profile_form_input.dart';
import '../widgets/profile_button.dart';
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
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Update Your Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep your account secure with a strong password',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Form Fields using reusable components
                ProfileFormInput(
                  label: 'Current Password',
                  controller: _currentPasswordController,
                  obscureText: !_isCurrentPasswordVisible,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
                  ),
                  isRequired: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Current password is required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                ProfileFormInput(
                  label: 'New Password',
                  controller: _newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_isNewPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                  ),
                  isRequired: true,
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
                
                const SizedBox(height: 20),
                
                ProfileFormInput(
                  label: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                  isRequired: true,
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
                
                const SizedBox(height: 32),
                
                // Security Tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Password Security Tips',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                                        color: Colors.blue.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Submit Button using reusable component
                ProfileButton(
                  text: 'Update Password',
                  onPressed: _handleChangePassword,
                  isLoading: _isLoading,
                  width: double.infinity,
                  height: 56,
                  backgroundColor: Colors.orange,
                  icon: Icons.lock_reset,
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
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
