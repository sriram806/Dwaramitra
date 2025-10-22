import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/entities/auth_entities.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<UserEntity> call(AuthCredentials credentials) async {
    // Business logic validation
    if (credentials.email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    
    if (credentials.password.isEmpty) {
      throw Exception('Password cannot be empty');
    }

    if (!_isValidEmail(credentials.email)) {
      throw Exception('Please enter a valid email address');
    }

    if (credentials.password.length < 6) {
      throw Exception('Password must be at least 6 characters long');
    }

    return await _authRepository.login(credentials);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}