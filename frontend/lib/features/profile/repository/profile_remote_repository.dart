import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/models/user_model.dart';

class ProfileRemoteRepository {
  final spService = SpService();

  // Get user profile from server
  Future<UserModel> getProfile() async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'Authentication token not found';
      }

      final response = await http.get(
        Uri.parse('${Constants.backendUri}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return UserModel.fromMap(data['user']);
        } else {
          throw 'Invalid response format';
        }
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Failed to fetch profile';
      }
    } catch (e) {
      throw 'Error fetching profile: $e';
    }
  }

  // Update user profile
  Future<UserModel> updateProfile({
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
      final token = await spService.getToken();
      if (token == null) {
        throw 'Authentication token not found';
      }

      // Build request body with only non-null values
      final Map<String, dynamic> requestBody = {
        'name': name,
      };
      
      if (email != null) requestBody['email'] = email;
      if (phone != null) requestBody['phone'] = phone;
      if (gender != null) requestBody['gender'] = gender;
      if (universityId != null) requestBody['universityId'] = universityId;
      if (department != null) requestBody['department'] = department;
      if (designation != null) requestBody['designation'] = designation;
      if (shift != null) requestBody['shift'] = shift;
      if (avatar != null) requestBody['avatar'] = avatar;

      final response = await http.put(
        Uri.parse('${Constants.backendUri}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return UserModel.fromMap(data['user']);
        } else {
          throw 'Invalid response format';
        }
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Failed to update profile';
      }
    } catch (e) {
      throw 'Error updating profile: $e';
    }
  }

  // Upload profile picture
  Future<UserModel> uploadProfilePicture({
    required String imagePath,
  }) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'Authentication token not found';
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Constants.backendUri}/user/avatar'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath('avatar', imagePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromMap(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Failed to upload profile picture';
      }
    } catch (e) {
      throw 'Error uploading profile picture: $e';
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'Authentication token not found';
      }

      final response = await http.put(
        Uri.parse('${Constants.backendUri}/user/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Failed to change password';
      }
    } catch (e) {
      throw 'Error changing password: $e';
    }
  }

  // Delete account
  Future<void> deleteAccount({
    required String password,
  }) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'Authentication token not found';
      }

      final response = await http.delete(
        Uri.parse('${Constants.backendUri}/user/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Failed to delete account';
      }
    } catch (e) {
      throw 'Error deleting account: $e';
    }
  }
}