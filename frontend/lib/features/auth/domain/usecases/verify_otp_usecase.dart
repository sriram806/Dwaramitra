import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/entities/auth_entities.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _authRepository;

  VerifyOtpUseCase(this._authRepository);

  Future<UserEntity> call(OtpVerification otpVerification) async {
    // Business logic validation
    if (otpVerification.otp.isEmpty) {
      throw Exception('OTP cannot be empty');
    }

    if (otpVerification.otp.length != 4) {
      throw Exception('OTP must be 4 digits long');
    }

    if (!_isValidOtp(otpVerification.otp)) {
      throw Exception('OTP must contain only numbers');
    }

    return await _authRepository.verifyOtp(otpVerification);
  }

  bool _isValidOtp(String otp) {
    return RegExp(r'^\d{4}$').hasMatch(otp);
  }
}