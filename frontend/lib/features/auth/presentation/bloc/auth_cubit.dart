import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/entities/auth_entities.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/features/auth/data/mappers/user_mapper.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required SignUpUseCase signUpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _signUpUseCase = signUpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _resendOtpUseCase = resendOtpUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase,
        super(AuthInitial());

  void getUserData() async {
    try {
      emit(AuthLoading());
      final userEntity = await _getCurrentUserUseCase.call();
      if (userEntity != null) {
        // Convert entity to model for state
        final userModel = UserMapper.toModel(userEntity, '');
        emit(AuthLoggedIn(userModel));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      print('Get user data error: $e');
      emit(AuthInitial());
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
    String? gender,
  }) async {
    try {
      emit(AuthLoading());
      final credentials = SignUpCredentials(
        name: name,
        email: email,
        password: password,
        gender: gender,
      );
      
      final userEntity = await _signUpUseCase.call(credentials);
      final userModel = UserMapper.toModel(userEntity, '');
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
      final credentials = AuthCredentials(
        email: email,
        password: password,
      );
      
      final userEntity = await _loginUseCase.call(credentials);
      final userModel = UserMapper.toModel(userEntity, '');
      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void verifyOtp({required String otp}) async {
    try {
      emit(AuthLoading());
      final otpVerification = OtpVerification(otp: otp);
      final userEntity = await _verifyOtpUseCase.call(otpVerification);
      final userModel = UserMapper.toModel(userEntity, '');
      emit(AuthOtpVerified(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void resendOtp() async {
    try {
      emit(AuthLoading());
      await _resendOtpUseCase.call();
      emit(AuthInitial()); // Return to initial state after resending
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void forgotPassword({required String email}) async {
    try {
      emit(AuthLoading());
      await _forgotPasswordUseCase.call(email);
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
      final passwordReset = PasswordReset(
        email: email,
        otp: otp,
        newPassword: password,
      );
      await _resetPasswordUseCase.call(passwordReset);
      emit(AuthPasswordReset());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void logout() async {
    try {
      emit(AuthLoading());
      await _logoutUseCase.call();
      emit(AuthInitial());
    } catch (e) {
      // Even if logout fails on server, clear local data
      emit(AuthInitial());
    }
  }
}
