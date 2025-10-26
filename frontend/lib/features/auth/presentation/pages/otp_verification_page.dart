import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_button.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/models/user_model.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationPage extends StatefulWidget {
  final UserModel user;

  static MaterialPageRoute route(UserModel user) => MaterialPageRoute(
        builder: (context) => OtpVerificationPage(user: user),
      );

  const OtpVerificationPage({super.key, required this.user});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final formKey = GlobalKey<FormState>();

  int _secondsRemaining = 30;
  bool _canResend = false;
  Timer? _timer;
  bool _isNavigating = false;
  bool _isDisposed = false;
  String _otpValue = '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    if (!mounted || _isDisposed) return;
    
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isDisposed) {
        timer.cancel();
        return;
      }
      
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpVerified && !_isNavigating) {
            _isNavigating = true;
            
            // Show success toast immediately
            CustomToast.showSuccess(
              context: context,
              message: 'OTP verified successfully! Redirecting...',
            );
            
            // Navigate immediately without delay
            if (mounted && !_isDisposed) {
              Navigator.pushAndRemoveUntil(
                context,
                HomePage.route(),
                (route) => false,
              );
            }
          } else if (state is AuthError) {
            CustomToast.showError(
              context: context,
              message: state.error,
              actionLabel: 'Try Again',
              onActionPressed: () {
                // You can retry OTP verification or resend
                if (mounted && !_isDisposed && _otpValue.length == 4) {
                  context.read<AuthCubit>().verifyOtp(otp: _otpValue);
                }
              },
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
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
                    Icons.email_outlined,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Verify Your Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: spacing),
                  Text(
                    'We sent a verification code to\n${widget.user.email}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),

                  // PinCodeField
                  PinCodeTextField(
                    appContext: context,
                    length: 4,
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
                    onChanged: (value) {
                      if (!mounted || _isDisposed) return;
                      _otpValue = value;
                      
                      // Trigger validation when user types
                      if (value.length == 4) {
                        formKey.currentState?.validate();
                      }
                    },
                    onCompleted: (value) {
                      if (!mounted || _isDisposed || _isNavigating) return;
                      
                      _otpValue = value;
                      // Auto-verify when OTP is complete
                      if (formKey.currentState!.validate()) {
                        context.read<AuthCubit>().verifyOtp(otp: value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP';
                      }
                      if (value.length != 4) {
                        return 'OTP must be 4 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Verify Button using AuthTextButton
                  AuthTextButton(
                    buttonText: 'Verify OTP',
                    onPressed: () {
                      if (!mounted || _isDisposed || _isNavigating) return;
                      
                      if (_otpValue.length == 4) {
                        context.read<AuthCubit>().verifyOtp(otp: _otpValue);
                      } else {
                        CustomToast.showError(
                          context: context,
                          message: 'Please enter complete 4-digit OTP',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: spacing),

                  // Resend OTP
                  TextButton(
                    onPressed: _canResend
                        ? () async {
                            if (!mounted || _isDisposed) return;
                            
                            try {
                              context.read<AuthCubit>().resendOtp();
                              
                              // Show success message immediately for better UX
                              if (mounted && !_isDisposed) {
                                CustomToast.showSuccess(
                                  context: context,
                                  message: 'OTP resent successfully to ${widget.user.email}',
                                );
                                
                                // Reset the timer
                                _startResendTimer();
                                
                                // Clear the current OTP value
                                _otpValue = '';
                              }
                            } catch (e) {
                              if (mounted && !_isDisposed) {
                                CustomToast.showError(
                                  context: context,
                                  message: 'Failed to resend OTP. Please try again.',
                                );
                              }
                            }
                          }
                        : null,
                    child: Text(_canResend
                        ? 'Resend OTP'
                        : 'Resend in $_secondsRemaining s'),
                  ),
                  const SizedBox(height: spacing),

                  // Change Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn't receive the code? "),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Change Email'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
          },
        ),
      ),
    );
  }
}
