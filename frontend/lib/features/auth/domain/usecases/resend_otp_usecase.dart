import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository _authRepository;

  ResendOtpUseCase(this._authRepository);

  Future<void> call() async {
    return await _authRepository.resendOtp();
  }
}