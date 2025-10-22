import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/entities/auth_entities.dart';

abstract class AuthRepository {
  /// Sign up a new user
  Future<UserEntity> signUp(SignUpCredentials credentials);

  /// Login with email and password
  Future<UserEntity> login(AuthCredentials credentials);

  /// Get current user data
  Future<UserEntity?> getCurrentUser();

  /// Verify OTP
  Future<UserEntity> verifyOtp(OtpVerification otpVerification);

  /// Resend OTP
  Future<void> resendOtp();

  /// Send forgot password OTP
  Future<void> forgotPassword(String email);

  /// Reset password with OTP
  Future<void> resetPassword(PasswordReset passwordReset);

  /// Logout user
  Future<void> logout();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}