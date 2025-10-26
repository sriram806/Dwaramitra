import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/announcement_model.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_repository.dart';

class AnnouncementRepository {
  static const String baseUrl = 'http://localhost:3000/api';
  final AuthLocalRepository _authLocalRepository = AuthLocalRepository();

  Future<Map<String, String>> _getHeaders() async {
    final user = await _authLocalRepository.getUser();
    final token = user?.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get active announcements for current user
  Future<Map<String, dynamic>> getActiveAnnouncements() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/announcements/active'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final announcements = (data['announcements'] as List)
            .map((announcement) => AnnouncementModel.fromMap(announcement))
            .toList();

        return {
          'success': true,
          'announcements': announcements,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch announcements',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Mark announcement as read
  Future<Map<String, dynamic>> markAnnouncementAsRead(String announcementId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/announcements/$announcementId/read'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark announcement as read',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Create announcement (Admin only)
  Future<Map<String, dynamic>> createAnnouncement({
    required String title,
    required String message,
    String type = 'info',
    String priority = 'medium',
    List<String>? targetAudience,
    DateTime? expiresAt,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = {
        'title': title,
        'message': message,
        'type': type,
        'priority': priority,
        'targetAudience': targetAudience ?? ['all'],
        'expiresAt': (expiresAt ?? DateTime.now().add(const Duration(days: 7))).toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/announcements'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'announcement': AnnouncementModel.fromMap(data['announcement']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create announcement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get all announcements (Admin only)
  Future<Map<String, dynamic>> getAllAnnouncements({
    int page = 1,
    int limit = 10,
    bool? isActive,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (isActive != null) {
        queryParams['isActive'] = isActive.toString();
      }

      final uri = Uri.parse('$baseUrl/announcements/all').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final announcements = (data['announcements'] as List)
            .map((announcement) => AnnouncementModel.fromMap(announcement))
            .toList();

        return {
          'success': true,
          'announcements': announcements,
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch announcements',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update announcement (Admin only)
  Future<Map<String, dynamic>> updateAnnouncement({
    required String id,
    String? title,
    String? message,
    String? type,
    String? priority,
    List<String>? targetAudience,
    DateTime? expiresAt,
    bool? isActive,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (message != null) body['message'] = message;
      if (type != null) body['type'] = type;
      if (priority != null) body['priority'] = priority;
      if (targetAudience != null) body['targetAudience'] = targetAudience;
      if (expiresAt != null) body['expiresAt'] = expiresAt.toIso8601String();
      if (isActive != null) body['isActive'] = isActive;

      final response = await http.put(
        Uri.parse('$baseUrl/announcements/$id'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'announcement': AnnouncementModel.fromMap(data['announcement']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update announcement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Delete announcement (Admin only)
  Future<Map<String, dynamic>> deleteAnnouncement(String id) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/announcements/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete announcement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}