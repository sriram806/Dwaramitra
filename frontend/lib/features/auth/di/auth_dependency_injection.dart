import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_repository.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_repository.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';

class AuthDependencyInjection {
  static AuthCubit getAuthCubit() {
    // Data sources
    final authRemoteRepository = AuthRemoteRepository();
    final authLocalRepository = AuthLocalRepository();
    final spService = SpService();

    // Repositories
    final authRepository = AuthRepositoryImpl(
      authRemoteRepository,
      authLocalRepository,
      spService,
    );

    // Use cases
    final loginUseCase = LoginUseCase(authRepository);
    final signUpUseCase = SignUpUseCase(authRepository);
    final verifyOtpUseCase = VerifyOtpUseCase(authRepository);
    final resendOtpUseCase = ResendOtpUseCase(authRepository);
    final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
    final resetPasswordUseCase = ResetPasswordUseCase(authRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);

    // Cubit
    return AuthCubit(
      loginUseCase: loginUseCase,
      signUpUseCase: signUpUseCase,
      verifyOtpUseCase: verifyOtpUseCase,
      resendOtpUseCase: resendOtpUseCase,
      forgotPasswordUseCase: forgotPasswordUseCase,
      resetPasswordUseCase: resetPasswordUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      logoutUseCase: logoutUseCase,
    );
  }
}