import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/profile/repository/profile_remote_repository.dart';
import 'package:frontend/features/profile/repository/profile_local_repository.dart';
import 'package:frontend/models/user_model.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final _remoteRepository = ProfileRemoteRepository();
  final _localRepository = ProfileLocalRepository();

  // Load profile data
  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());

      // First try to get cached data
      UserModel? cachedUser = await _localRepository.getCachedProfile();
      if (cachedUser != null) {
        emit(ProfileLoaded(cachedUser));
        return;
      }

      // If no cache, get from local storage
      UserModel? localUser = await _localRepository.getUserProfile();
      if (localUser != null) {
        emit(ProfileLoaded(localUser));
        
        // Try to refresh from server in background
        _refreshProfileInBackground();
        return;
      }

      // If no local data, fetch from server
      UserModel user = await _remoteRepository.getProfile();
      await _localRepository.saveUserProfile(user);
      await _localRepository.cacheProfileData(user);
      await _localRepository.setSyncStatus(true);
      
      emit(ProfileLoaded(user));
    } catch (e) {
      // If we have local data, use it even if server fails
      UserModel? localUser = await _localRepository.getUserProfile();
      if (localUser != null) {
        emit(ProfileLoaded(localUser));
        emit(ProfileError('Failed to sync with server: $e'));
      } else {
        emit(ProfileError('Failed to load profile: $e'));
      }
    }
  }

  // Refresh profile from server
  Future<void> refreshProfile() async {
    try {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        emit(ProfileRefreshing(currentState.user));
      } else {
        emit(ProfileLoading());
      }

      UserModel user = await _remoteRepository.getProfile();
      await _localRepository.saveUserProfile(user);
      await _localRepository.cacheProfileData(user);
      await _localRepository.setSyncStatus(true);
      
      emit(ProfileLoaded(user));
    } catch (e) {
      final localUser = await _localRepository.getUserProfile();
      if (localUser != null) {
        emit(ProfileLoaded(localUser));
      }
      emit(ProfileError('Failed to refresh profile: $e'));
    }
  }

  // Update profile
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
      final currentState = state;
      if (currentState is ProfileLoaded) {
        emit(ProfileUpdating(currentState.user));
      }

      UserModel updatedUser = await _remoteRepository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        gender: gender,
        universityId: universityId,
        department: department,
        designation: designation,
        shift: shift,
        avatar: avatar,
      );

      await _localRepository.saveUserProfile(updatedUser);
      await _localRepository.cacheProfileData(updatedUser);
      await _localRepository.setSyncStatus(true);
      
      emit(ProfileUpdated(updatedUser));
      emit(ProfileLoaded(updatedUser));
    } catch (e) {
      // Save locally if server update fails
      await _localRepository.updateProfileFields(
        name: name,
        email: email,
        phone: phone,
        gender: gender,
        universityId: universityId,
        department: department,
        designation: designation,
        shift: shift,
      );
      await _localRepository.setSyncStatus(false);
      
      final localUser = await _localRepository.getUserProfile();
      if (localUser != null) {
        emit(ProfileLoaded(localUser));
      }
      
      emit(ProfileError('Profile saved locally. Will sync when online: $e'));
    }
  }

  // Upload profile picture
  Future<void> uploadProfilePicture(String imagePath) async {
    try {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        emit(ProfileUpdating(currentState.user));
      }

      UserModel updatedUser = await _remoteRepository.uploadProfilePicture(
        imagePath: imagePath,
      );

      await _localRepository.saveUserProfile(updatedUser);
      await _localRepository.cacheProfileData(updatedUser);
      await _localRepository.setSyncStatus(true);
      
      emit(ProfilePictureUpdated(updatedUser));
      emit(ProfileLoaded(updatedUser));
    } catch (e) {
      final localUser = await _localRepository.getUserProfile();
      if (localUser != null) {
        emit(ProfileLoaded(localUser));
      }
      emit(ProfileError('Failed to upload profile picture: $e'));
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      emit(ProfilePasswordChanging());

      await _remoteRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      emit(ProfilePasswordChanged());
      
      // Reload profile to ensure we have latest data
      await loadProfile();
    } catch (e) {
      final localUser = await _localRepository.getUserProfile();
      if (localUser != null) {
        emit(ProfileLoaded(localUser));
      }
      emit(ProfileError('Failed to change password: $e'));
    }
  }

  // Delete account
  Future<void> deleteAccount(String password) async {
    try {
      emit(ProfileDeleting());

      await _remoteRepository.deleteAccount(password: password);
      await _localRepository.clearAllProfileData();
      
      emit(ProfileDeleted());
    } catch (e) {
      final localUser = await _localRepository.getUserProfile();
      if (localUser != null) {
        emit(ProfileLoaded(localUser));
      }
      emit(ProfileError('Failed to delete account: $e'));
    }
  }

  // Sync profile with server
  Future<void> syncProfile() async {
    try {
      final isAlreadySynced = await _localRepository.getSyncStatus();
      if (isAlreadySynced) {
        return; // Already synced
      }

      final localUser = await _localRepository.getUserProfile();
      if (localUser == null) {
        return; // No local data to sync
      }

      emit(ProfileSyncing(localUser));

      // Update server with local changes
      UserModel syncedUser = await _remoteRepository.updateProfile(
        name: localUser.name,
        email: localUser.email,
        phone: localUser.phone,
        gender: localUser.gender,
        universityId: localUser.universityId,
        department: localUser.department,
        designation: localUser.designation,
        avatar: localUser.avatar?.toMap(),
      );

      await _localRepository.saveUserProfile(syncedUser);
      await _localRepository.cacheProfileData(syncedUser);
      await _localRepository.setSyncStatus(true);
      
      emit(ProfileSynced(syncedUser));
      emit(ProfileLoaded(syncedUser));
    } catch (e) {
      final localUser = await _localRepository.getUserProfile();
      if (localUser != null) {
        emit(ProfileLoaded(localUser));
      }
      emit(ProfileError('Failed to sync profile: $e'));
    }
  }

  // Background refresh
  Future<void> _refreshProfileInBackground() async {
    try {
      UserModel user = await _remoteRepository.getProfile();
      await _localRepository.saveUserProfile(user);
      await _localRepository.cacheProfileData(user);
      await _localRepository.setSyncStatus(true);
      
      // Update state if current user is outdated
      final currentState = state;
      if (currentState is ProfileLoaded) {
        if (currentState.user.updatedAt.isBefore(user.updatedAt)) {
          emit(ProfileLoaded(user));
        }
      }
    } catch (e) {
      // Silently fail background refresh
      print('Background profile refresh failed: $e');
    }
  }

  // Clear profile data
  Future<void> clearProfile() async {
    try {
      await _localRepository.clearAllProfileData();
      emit(ProfileInitial());
    } catch (e) {
      emit(ProfileError('Failed to clear profile data: $e'));
    }
  }
}