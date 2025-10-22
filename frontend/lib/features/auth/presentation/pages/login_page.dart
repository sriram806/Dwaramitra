import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/pages/signup_page.dart';
import 'package:frontend/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_header.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_card.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_field.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_button.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_navigation_text.dart';
import 'package:frontend/features/home/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const LoginPage(),
      );
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
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
              actionLabel: 'Retry',
              onActionPressed: () {
                loginUser();
              },
            );
          } else if (state is AuthLoggedIn) {
            CustomToast.showSuccess(
              context: context,
              message: 'Welcome back, ${state.user.name}!',
            );
            Future.microtask(() {
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  HomePage.route(),
                  (_) => false,
                );
              }
            });
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    
                    // Header with logo and welcome text
                    const AuthHeader(
                      title: "Welcome to Dwaramitra",
                      subtitle: "Your Smart Gateway to Secure\nVehicle Management",
                    ),
                    
                    const SizedBox(height: 30),

                    // Card container for form
                    AuthCard(
                      title: "Enter Login Details",
                      child: Column(
                        children: [
                          // Email field
                          AuthField(
                            hintText: 'Email',
                            controller: emailController,
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.trim().contains("@")) {
                                return "Enter a valid email!";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Password field
                          AuthField(
                            hintText: 'Password',
                            controller: passwordController,
                            prefixIcon: Icons.lock,
                            isObscureText: true,
                            enableTogglePassword: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 6) {
                                return "Password must be at least 6 chars!";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  ForgotPasswordPage.route(),
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          
                          // Login button
                          AuthTextButton(
                            buttonText: "Login",
                            onPressed: loginUser,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),
                    
                    // Navigation to signup
                    AuthNavigationText(
                      leadingText: "Don't have an account? ",
                      actionText: "Get Started",
                      onTap: () {
                        Navigator.of(context).push(SignupPage.route());
                      },
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
