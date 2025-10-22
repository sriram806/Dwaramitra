import 'package:frontend/features/auth/domain/entities/auth_entities.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<void> call(PasswordReset passwordReset) async {
    // Business logic validation
    if (passwordReset.email.isEmpty) {
      throw Exception('Email cannot be empty');
    }

    if (passwordReset.otp.isEmpty) {
      throw Exception('OTP cannot be empty');
    }

    if (passwordReset.newPassword.isEmpty) {
      throw Exception('New password cannot be empty');
    }

    if (!_isValidEmail(passwordReset.email)) {
      throw Exception('Please enter a valid email address');
    }

    if (passwordReset.otp.length != 4) {
      throw Exception('OTP must be 4 digits long');
    }

    if (!_isValidOtp(passwordReset.otp)) {
      throw Exception('OTP must contain only numbers');
    }

    if (passwordReset.newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters long');
    }

    if (!_isStrongPassword(passwordReset.newPassword)) {
      throw Exception('Password must contain at least one uppercase letter, one lowercase letter, and one number');
    }

    return await _authRepository.resetPassword(passwordReset);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _isValidOtp(String otp) {
    return RegExp(r'^\d{4}$').hasMatch(otp);
  }

  bool _isStrongPassword(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(password);
  }
}