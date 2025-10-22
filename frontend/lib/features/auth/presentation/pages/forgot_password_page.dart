import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/pages/reset_password_page.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_field.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(),
      );
      
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetOtpSent) {
            CustomToast.showSuccess(
              context: context,
              message: 'Reset code sent to your email!',
            );
            Navigator.push(
              context,
              ResetPasswordPage.route(emailController.text.trim()),
            );
          } else if (state is AuthError) {
            CustomToast.showError(
              context: context,
              message: state.error,
              actionLabel: 'Retry',
              onActionPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<AuthCubit>().forgotPassword(
                    email: emailController.text.trim(),
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
                    'Reset Password',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter your email address and we\'ll send you a 4-digit code to reset your password.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Email field using AuthField widget
                  AuthField(
                    hintText: 'Email Address',
                    controller: emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Send reset code button
                  AuthTextButton(
                    buttonText: 'Send Reset Code',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthCubit>().forgotPassword(
                              email: emailController.text.trim(),
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Login'),
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
