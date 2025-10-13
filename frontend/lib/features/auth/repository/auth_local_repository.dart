import 'package:frontend/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class AuthLocalRepository {
  static const String _userKey = "user_data";

  Future<void> insertUser(UserModel userModel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(userModel.toMap());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromMap(userMap);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }

  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing user data: $e');
      }
    }
  }

  Future<bool> hasUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user data: $e');
      }
      return false;
    }
  }
}
