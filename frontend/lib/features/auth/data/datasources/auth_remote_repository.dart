import 'dart:convert';

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_repository.dart';
import 'package:frontend/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteRepository {
  final spService = SpService();
  final authLocalRepository = AuthLocalRepository();

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? gender,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/register',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          if (gender != null) 'gender': gender,
        }),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 201) {
        throw body['message'] ?? 'Registration failed';
      }

      await spService.setToken(body['token']);
      
      final userData = body['data']['user'];
      userData['token'] = body['token'];
      
      return UserModel.fromMap(userData);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/login',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Login failed';
      }

      await spService.setToken(body['token']);
      
      final userData = body['data']['user'];
      userData['token'] = body['token'];
      
      return UserModel.fromMap(userData);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        return null;
      }

      final userResponse = await http.get(
        Uri.parse(
          '${Constants.backendUri}/user/profile',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(userResponse.body);
      
      if (userResponse.statusCode != 200) {
        throw body['message'] ?? 'Failed to get user data';
      }
      
      final userData = body['user'];
      userData['token'] = token;
      
      return UserModel.fromMap(userData);
    } catch (e) {
      final user = await authLocalRepository.getUser();
      return user;
    }
  }

  Future<UserModel> verifyOtp({required String otp}) async {
    try {
      final token = await spService.getToken();
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otp': otp,
        }),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'OTP verification failed';
      }

      if (body['token'] != null) {
        await spService.setToken(body['token']);
      }
      
      final userData = body['data']['user'];
      userData['token'] = body['token'];
      
      return UserModel.fromMap(userData);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> resendOtp() async {
    try {
      final token = await spService.getToken();
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to resend OTP';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to send reset OTP';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
        }),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Password reset failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    try {
      final token = await spService.getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${Constants.backendUri}/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
      
      await spService.clearToken();
    } catch (e) {
      await spService.clearToken();
      throw e.toString();
    }
  }
}
