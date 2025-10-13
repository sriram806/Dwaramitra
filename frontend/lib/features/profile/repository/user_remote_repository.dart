import 'dart:convert';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/models/user_model.dart';
import 'package:http/http.dart' as http;

class UserRemoteRepository {
  final spService = SpService();

  Future<UserModel> getProfile() async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final res = await http.get(
        Uri.parse('${Constants.backendUri}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to get profile';
      }
      
      // Add token to user data for consistency
      final userData = body['user'];
      userData['token'] = token;
      
      return UserModel.fromMap(userData);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    Map<String, dynamic>? avatar,
  }) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final Map<String, dynamic> requestBody = {};
      if (name != null) requestBody['name'] = name;
      if (email != null) requestBody['email'] = email;
      if (phone != null) requestBody['phone'] = phone;
      if (avatar != null) requestBody['avatar'] = avatar;

      final res = await http.put(
        Uri.parse('${Constants.backendUri}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to update profile';
      }
      
      // Add token to user data for consistency
      final userData = body['user'];
      userData['token'] = token;
      
      return UserModel.fromMap(userData);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<String>> getSavedItems() async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final res = await http.get(
        Uri.parse('${Constants.backendUri}/user/saved-items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to get saved items';
      }
      
      final List<dynamic> items = body['savedItems'] ?? [];
      return items.map((item) => item.toString()).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<String>> addSavedItem(String itemId) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/user/saved-items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'itemId': itemId}),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to add saved item';
      }
      
      final List<dynamic> items = body['savedItems'] ?? [];
      return items.map((item) => item.toString()).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<String>> removeSavedItem(String itemId) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final res = await http.delete(
        Uri.parse('${Constants.backendUri}/user/saved-items/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to remove saved item';
      }
      
      final List<dynamic> items = body['savedItems'] ?? [];
      return items.map((item) => item.toString()).toList();
    } catch (e) {
      throw e.toString();
    }
  }
}