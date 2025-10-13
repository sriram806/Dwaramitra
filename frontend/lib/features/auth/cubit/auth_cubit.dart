import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/repository/auth_local_repository.dart';
import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:frontend/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();
  final authLocalRepository = AuthLocalRepository();
  final spService = SpService();

  void getUserData() async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.getUserData();
      if (userModel != null) {
        try {
          await authLocalRepository.insertUser(userModel);
        } catch (e) {
          // Ignore local storage errors (e.g., on web)
          print('Local storage warning: $e');
        }
        emit(AuthLoggedIn(userModel));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      print(e);
      emit(AuthInitial());
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
      );

      try {
        await authLocalRepository.insertUser(userModel);
      } catch (e) {
        // Ignore local storage errors (e.g., on web)
        print('Local storage warning: $e');
      }
      emit(AuthSignUp(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.login(
        email: email,
        password: password,
      );

      if (userModel.token.isNotEmpty) {
        await spService.setToken(userModel.token);
      }

      try {
        await authLocalRepository.insertUser(userModel);
      } catch (e) {
        // Ignore local storage errors (e.g., on web)
        print('Local storage warning: $e');
      }

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void verifyOtp({required String otp}) async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.verifyOtp(
        otp: otp,
      );
      
      try {
        await authLocalRepository.insertUser(userModel);
      } catch (e) {
        // Ignore local storage errors (e.g., on web)
        print('Local storage warning: $e');
      }
      emit(AuthOtpVerified(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void resendOtp() async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.resendOtp();
      emit(AuthInitial()); // Return to initial state after resending
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void forgotPassword({required String email}) async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.forgotPassword(email: email);
      emit(AuthPasswordResetOtpSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.resetPassword(
        email: email,
        otp: otp,
        password: password,
      );
      emit(AuthPasswordReset());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void logout() async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.logout();
      try {
        await authLocalRepository.clearUser();
      } catch (e) {
        print('Local storage warning: $e');
      }
      emit(AuthInitial());
    } catch (e) {
      // Even if logout fails on server, clear local data
      try {
        await authLocalRepository.clearUser();
      } catch (e) {
        print('Local storage warning: $e');
      }
      emit(AuthInitial());
    }
  }
}
