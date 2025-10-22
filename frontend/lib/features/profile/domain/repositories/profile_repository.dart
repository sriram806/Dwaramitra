import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
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
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> deleteAccount(String password);
  Future<void> refreshProfile();
  Future<void> clearLocalData();
}