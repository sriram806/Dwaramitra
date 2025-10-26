import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  
  ProfileCubit({required this.repository}) : super(ProfileInitial());

  // Load profile data from API
  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());
      final profile = await repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> refreshProfile() async {
    try {
      await repository.refreshProfile();
      final profile = await repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? gender,
    String? universityId,
    String? department,
    String? designation,
    String? shift,
    Map<String, dynamic>? avatar,
  }) async {
    try {
      emit(ProfileLoading());
      
      // Convert avatar map to string map if provided
      Map<String, String>? avatarStringMap;
      if (avatar != null) {
        avatarStringMap = avatar.map((key, value) => MapEntry(key, value.toString()));
      }
      
      final updatedProfile = await repository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        gender: gender,
        universityId: universityId,
        department: department,
        designation: designation,
        shift: shift,
        avatar: avatarStringMap,
      );
      
      // Convert ProfileEntity back to UserModel for consistency with UI
      emit(ProfileUpdated(updatedProfile));
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
    }
  }

  // Change password using API
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      emit(ProfileLoading());
      await repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(ProfilePasswordChanged());
    } catch (e) {
      emit(ProfileError('Failed to change password: $e'));
    }
  }

  // Delete account using API
  Future<void> deleteAccount(String password) async {
    try {
      emit(ProfileLoading());
      await repository.deleteAccount(password);
      emit(ProfileDeleted());
    } catch (e) {
      emit(ProfileError('Failed to delete account: $e'));
    }
  }

  // Clear local data
  Future<void> clearLocalData() async {
    try {
      await repository.clearLocalData();
      emit(ProfileInitial());
    } catch (e) {
      emit(ProfileError('Failed to clear local data: $e'));
    }
  }
}
