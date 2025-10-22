import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/entities/auth_entities.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  Future<UserEntity> call(SignUpCredentials credentials) async {
    // Business logic validation
    if (credentials.name.isEmpty) {
      throw Exception('Name cannot be empty');
    }

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

    if (credentials.name.length < 2) {
      throw Exception('Name must be at least 2 characters long');
    }

    // Check if password is strong enough
    if (!_isStrongPassword(credentials.password)) {
      throw Exception('Password must contain at least one uppercase letter, one lowercase letter, and one number');
    }

    return await _authRepository.signUp(credentials);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    // Check for at least one uppercase, one lowercase, and one number
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(password);
  }
}