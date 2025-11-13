import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';

class ApiService {
  static final SpService _spService = SpService();

  static Future<Map<String, dynamic>> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request();
      final responseBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        throw Exception(responseBody['message'] ?? 'Request failed with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final token = await _spService.getToken();
    final uri = Uri.parse('${Constants.backendUri}$endpoint')
        .replace(queryParameters: queryParameters);

    return _makeRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
            ...?headers,
          },
        ));
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? data,
  }) async {
    final token = await _spService.getToken();
    final uri = Uri.parse('${Constants.backendUri}$endpoint');

    return _makeRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
            ...?headers,
          },
          body: jsonEncode(data),
        ));
  }

  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? data,
  }) async {
    final token = await _spService.getToken();
    final uri = Uri.parse('${Constants.backendUri}$endpoint');

    return _makeRequest(() => http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
            ...?headers,
          },
          body: jsonEncode(data),
        ));
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final token = await _spService.getToken();
    final uri = Uri.parse('${Constants.backendUri}$endpoint');

    return _makeRequest(() => http.delete(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
            ...?headers,
          },
        ));
  }
}