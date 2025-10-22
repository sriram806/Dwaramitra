import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_field.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  
  static MaterialPageRoute route(String email) => MaterialPageRoute(
        builder: (context) => ResetPasswordPage(email: email),
      );
      
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordReset) {
            CustomToast.showSuccess(
              context: context,
              message: 'Password reset successfully! Please login.',
            );
            Navigator.pushAndRemoveUntil(
              context,
              LoginPage.route(),
              (route) => false,
            );
          } else if (state is AuthError) {
            CustomToast.showError(
              context: context,
              message: state.error,
              actionLabel: 'Retry',
              onActionPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<AuthCubit>().resetPassword(
                    email: widget.email,
                    otp: otpController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                }
              },
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Reset Your Password',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter the 4-digit code sent to ${widget.email} and your new password.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Reset Code Label
                  Text(
                    'Enter Reset Code',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // PinCodeField for Reset Code
                  PinCodeTextField(
                    appContext: context,
                    length: 4,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    autoFocus: true,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 60,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                      selectedFillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      inactiveFillColor: Colors.grey.shade50,
                      selectedColor: Theme.of(context).primaryColor,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.grey.shade300,
                    ),
                    enableActiveFill: true,
                    onChanged: (_) {},
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the reset code';
                      }
                      if (value.length != 4) {
                        return 'Code must be 4 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // New Password field
                  AuthField(
                    hintText: 'New Password',
                    controller: passwordController,
                    prefixIcon: Icons.lock_outline,
                    isObscureText: true,
                    enableTogglePassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm Password field
                  AuthField(
                    hintText: 'Confirm Password',
                    controller: confirmPasswordController,
                    prefixIcon: Icons.lock_outline,
                    isObscureText: true,
                    enableTogglePassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Reset Password button
                  AuthTextButton(
                    buttonText: 'Reset Password',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthCubit>().resetPassword(
                              email: widget.email,
                              otp: otpController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
