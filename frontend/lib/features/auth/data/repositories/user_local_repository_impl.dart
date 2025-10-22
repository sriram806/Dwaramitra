import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/user_local_repository.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_repository.dart';
import 'package:frontend/features/auth/data/mappers/user_mapper.dart';

class UserLocalRepositoryImpl implements UserLocalRepository {
  final AuthLocalRepository _authLocalRepository;

  UserLocalRepositoryImpl(this._authLocalRepository);

  @override
  Future<void> saveUser(UserEntity user) async {
    try {
      // Convert entity to model for storage
      final userModel = UserMapper.toModel(user, ''); // Token handled separately
      await _authLocalRepository.insertUser(userModel);
    } catch (e) {
      throw Exception('Failed to save user locally: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getUser() async {
    try {
      final userModel = await _authLocalRepository.getUser();
      if (userModel != null) {
        return UserMapper.toEntity(userModel);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user from local storage: ${e.toString()}');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _authLocalRepository.clearUser();
    } catch (e) {
      throw Exception('Failed to clear user from local storage: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasUser() async {
    try {
      return await _authLocalRepository.hasUser();
    } catch (e) {
      return false;
    }
  }
}