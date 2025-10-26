import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user_model.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({
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
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final spService = SpService();
  
  ProfileRemoteDataSourceImpl({
    required this.client,
  });

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await spService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.get(
        Uri.parse('${Constants.backendUri}/user/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return UserModel.fromMap(data['user']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<UserModel> updateProfile({
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
      final headers = await _getAuthHeaders();
      
      // Build request body with only non-null values
      final Map<String, dynamic> requestBody = {};
      if (name != null) requestBody['name'] = name;
      if (email != null) requestBody['email'] = email;
      if (phone != null) requestBody['phone'] = phone;
      if (gender != null) requestBody['gender'] = gender;
      if (universityId != null) requestBody['universityId'] = universityId;
      if (department != null) requestBody['department'] = department;
      if (designation != null) requestBody['designation'] = designation;
      if (shift != null) requestBody['shift'] = shift;
      if (avatar != null) requestBody['avatar'] = avatar;

      final response = await client.put(
        Uri.parse('${Constants.backendUri}/user/profile'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return UserModel.fromMap(data['user']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
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
      final headers = await _getAuthHeaders();
      final response = await client.put(
        Uri.parse('${Constants.backendUri}/user/change-password'),
        headers: headers,
        body: jsonEncode({
          'oldPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.delete(
        Uri.parse('${Constants.backendUri}/user/delete-account'),
        headers: headers,
        body: jsonEncode({
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}