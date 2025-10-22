import 'package:frontend/features/auth/domain/entities/user_entity.dart';

abstract class UserLocalRepository {
  /// Save user data locally
  Future<void> saveUser(UserEntity user);

  /// Get saved user data
  Future<UserEntity?> getUser();

  /// Clear saved user data
  Future<void> clearUser();

  /// Check if user data exists locally
  Future<bool> hasUser();
}