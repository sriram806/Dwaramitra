import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_header.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_card.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_field.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_button.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_navigation_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const SignupPage(),
      );
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isNavigating = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void signUpUser() {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            CustomToast.showError(
              context: context,
              message: state.error,
              actionLabel: 'Try Again',
              onActionPressed: () {
                signUpUser();
              },
            );
          } else if (state is AuthSignUp && !_isNavigating) {
            _isNavigating = true;
            CustomToast.showSuccess(
              context: context,
              message: 'Account created successfully! Please verify your email.',
            );
            Future.microtask(() {
              if (mounted) {
                Navigator.push(
                  context,
                  OtpVerificationPage.route(state.user),
                );
              }
            });
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header with logo and welcome text
                    const AuthHeader(
                      title: "Welcome to Dwaramitra",
                      subtitle: "Your Smart Gateway to Secure\nVehicle Management",
                    ),
                    
                    const SizedBox(height: 25),

                    // Card Container
                    AuthCard(
                      title: "Enter Registration Details",
                      child: Column(
                        children: [
                          // Name
                          AuthField(
                            hintText: "Name",
                            controller: nameController,
                            prefixIcon: Icons.person,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Name field cannot be empty!";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Email
                          AuthField(
                            hintText: "Email",
                            controller: emailController,
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty || !value.contains("@")) {
                                return "Enter a valid email!";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Password
                          AuthField(
                            hintText: "Password",
                            controller: passwordController,
                            prefixIcon: Icons.lock,
                            isObscureText: true,
                            enableTogglePassword: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length <= 6) {
                                return "Password must be at least 7 characters!";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),

                          // Sign up button
                          AuthTextButton(
                            buttonText: 'Sign up',
                            onPressed: signUpUser,
                            fontSize: 18,
                          ),
                          const SizedBox(height: 15),

                          // Navigate to Login
                          AuthNavigationText(
                            leadingText: 'Already registered? ',
                            actionText: 'Login Here',
                            onTap: () {
                              Navigator.of(context).push(LoginPage.route());
                            },
                            actionColor: Colors.orange.shade800,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
