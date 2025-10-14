import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/user_model.dart';

class ProfileLocalRepository {
  static const String _userKey = "user_data";
  static const String _profileCacheKey = "profile_cache";

  // Save user profile to local storage
  Future<void> saveUserProfile(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, user.toJson());
      
      // Also save to profile cache for quick access
      await prefs.setString(_profileCacheKey, user.toJson());
    } catch (e) {
      print('Error saving user profile to local storage: $e');
      rethrow;
    }
  }

  // Get user profile from local storage
  Future<UserModel?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        return UserModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      print('Error getting user profile from local storage: $e');
      return null;
    }
  }

  // Update specific profile fields locally
  Future<void> updateProfileFields({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? universityId,
    String? department,
    String? designation,
    String? shift,
  }) async {
    try {
      final currentUser = await getUserProfile();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          name: name ?? currentUser.name,
          email: email ?? currentUser.email,
          phone: phone ?? currentUser.phone,
          gender: gender ?? currentUser.gender,
          universityId: universityId ?? currentUser.universityId,
          department: department ?? currentUser.department,
          designation: designation ?? currentUser.designation,
          shift: shift ?? currentUser.shift,
        );
        await saveUserProfile(updatedUser);
      }
    } catch (e) {
      print('Error updating profile fields locally: $e');
      rethrow;
    }
  }

  // Cache profile data with timestamp
  Future<void> cacheProfileData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'user': user.toMap(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_profileCacheKey, jsonEncode(cacheData));
    } catch (e) {
      print('Error caching profile data: $e');
    }
  }

  // Get cached profile data
  Future<UserModel?> getCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_profileCacheKey);
      
      if (cacheJson != null) {
        final cacheData = jsonDecode(cacheJson);
        final timestamp = DateTime.parse(cacheData['timestamp']);
        
        // Check if cache is less than 1 hour old
        if (DateTime.now().difference(timestamp).inHours < 1) {
          return UserModel.fromMap(cacheData['user']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting cached profile: $e');
      return null;
    }
  }

  // Clear profile cache
  Future<void> clearProfileCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileCacheKey);
    } catch (e) {
      print('Error clearing profile cache: $e');
    }
  }

  // Clear all profile data
  Future<void> clearAllProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_profileCacheKey);
    } catch (e) {
      print('Error clearing all profile data: $e');
    }
  }

  // Check if profile data exists
  Future<bool> hasProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userKey);
    } catch (e) {
      print('Error checking profile data existence: $e');
      return false;
    }
  }

  // Sync status management
  Future<void> setSyncStatus(bool synced) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('profile_synced', synced);
    } catch (e) {
      print('Error setting sync status: $e');
    }
  }

  Future<bool> getSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('profile_synced') ?? false;
    } catch (e) {
      print('Error getting sync status: $e');
      return false;
    }
  }
}