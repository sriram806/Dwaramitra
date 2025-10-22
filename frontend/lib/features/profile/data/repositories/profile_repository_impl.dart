import 'package:frontend/models/user_model.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<ProfileEntity> getProfile() async {
    try {
      // Try to get from remote first
      final profile = await remoteDataSource.getProfile('current_user');
      await localDataSource.cacheProfile(profile);
      return _mapUserModelToEntity(profile);
    } catch (e) {
      // Fallback to cached data
      final cachedProfile = await localDataSource.getCachedProfile();
      if (cachedProfile != null) {
        return _mapUserModelToEntity(cachedProfile);
      }
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<ProfileEntity> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? universityId,
    String? department,
    String? designation,
    String? shift,
    Map<String, String>? avatar,
  }) async {
    try {
      // Get current profile
      final currentProfile = await localDataSource.getCachedProfile();
      if (currentProfile == null) {
        throw Exception('No profile found to update');
      }

      // Create updated profile
      final updatedProfile = UserModel(
        id: currentProfile.id,
        name: name ?? currentProfile.name,
        email: email ?? currentProfile.email,
        phone: phone ?? currentProfile.phone,
        gender: gender ?? currentProfile.gender,
        universityId: universityId ?? currentProfile.universityId,
        department: department ?? currentProfile.department,
        designation: designation ?? currentProfile.designation,
        shift: shift ?? currentProfile.shift,
        avatar: currentProfile.avatar,
        token: currentProfile.token,
        isAccountVerified: currentProfile.isAccountVerified,
        role: currentProfile.role,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await remoteDataSource.updateProfile(updatedProfile);
      await localDataSource.cacheProfile(result);
      return _mapUserModelToEntity(result);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      await remoteDataSource.deleteAccount('current_user');
      await localDataSource.clearLocalData();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  @override
  Future<void> refreshProfile() async {
    try {
      final profile = await remoteDataSource.getProfile('current_user');
      await localDataSource.cacheProfile(profile);
    } catch (e) {
      throw Exception('Failed to refresh profile: $e');
    }
  }

  @override
  Future<void> clearLocalData() async {
    try {
      await localDataSource.clearLocalData();
    } catch (e) {
      throw Exception('Failed to clear local data: $e');
    }
  }

  ProfileEntity _mapUserModelToEntity(UserModel model) {
    return ProfileEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      gender: model.gender,
      universityId: model.universityId,
      department: model.department,
      designation: model.designation,
      shift: model.shift,
      avatar: model.avatar != null && model.avatar!.url != null ? ProfileAvatarEntity(
        url: model.avatar!.url!,
        publicId: model.avatar!.publicId ?? '',
      ) : null,
      isAccountVerified: model.isAccountVerified,
      role: model.role,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}