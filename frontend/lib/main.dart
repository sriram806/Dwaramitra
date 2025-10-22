import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/auth/di/auth_dependency_injection.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/pages/signup_page.dart';
import 'package:frontend/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:frontend/features/home/cubit/tasks_cubit.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:frontend/features/profile/di/profile_injection.dart';
import 'package:frontend/features/vehicles/cubit/vehicle_cubit.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthDependencyInjection.getAuthCubit()),
        BlocProvider(create: (_) => TasksCubit()),
        BlocProvider(create: (_) => ProfileDependencyInjection.getProfileCubit()),
        BlocProvider(create: (_) => VehicleCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      theme: AppTheme.lightThemeMode,
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoggedIn) {
            // Check if account is verified
            if (state.user.isAccountVerified) {
              return const HomePage();
            } else {
              // Show OTP verification if account is not verified
              return OtpVerificationPage(user: state.user);
            }
          }
          return const SignupPage();
        },
      ),
    );
  }
}
