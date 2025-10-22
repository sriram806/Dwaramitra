import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/user_model.dart';

abstract class ProfileLocalDataSource {
  Future<void> cacheProfile(UserModel profile);
  Future<UserModel?> getCachedProfile();
  Future<void> clearLocalData();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _profileCacheKey = 'profile_cache';
  static const String _userKey = 'user_profile';

  @override
  Future<void> cacheProfile(UserModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toJson());
      await prefs.setString(_profileCacheKey, profileJson);
    } catch (e) {
      throw Exception('Failed to cache profile: $e');
    }
  }

  @override
  Future<UserModel?> getCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileCacheKey);
      
      if (profileJson != null) {
        return UserModel.fromJson(profileJson);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get cached profile: $e');
    }
  }

  @override
  Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileCacheKey);
      await prefs.remove(_userKey);
    } catch (e) {
      throw Exception('Failed to clear local data: $e');
    }
  }
}