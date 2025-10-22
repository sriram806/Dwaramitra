import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _authRepository;

  ForgotPasswordUseCase(this._authRepository);

  Future<void> call(String email) async {
    // Business logic validation
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }

    return await _authRepository.forgotPassword(email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}