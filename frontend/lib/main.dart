import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/auth/di/auth_dependency_injection.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/profile/di/profile_injection.dart';
import 'package:frontend/features/vehicles/presentation/bloc/vehicle_cubit.dart';
import 'package:frontend/features/vehicles/presentation/bloc/vehicle_log_cubit.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthDependencyInjection.getAuthCubit()),
        BlocProvider(create: (_) => ProfileDependencyInjection.getProfileCubit()),
        BlocProvider(create: (_) => VehicleCubit()),
        BlocProvider(create: (_) => VehicleLogCubit()),
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
      title: 'Vehicle Management App',
      theme: AppTheme.lightThemeMode,
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoggedIn) {
            if (state.user.isAccountVerified) {
              return const HomePage();
            } else {
              return OtpVerificationPage(user: state.user);
            }
          } else if (state is AuthSignUp) {
            return OtpVerificationPage(user: state.user);
          }
          return const LoginPage();
        },
      ),
    );
  }
}
