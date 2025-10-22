import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/models/vehicle_model.dart';

class VehicleRepository {
  final SpService _spService = SpService();
  
  String get baseUrl => '${Constants.backendUri}/api/v1/vehicles';

  // Add new vehicle
  Future<VehicleModel> addVehicle({
    required String vehicleNumber,
    required String vehicleType,
    required String ownerName,
    required String ownerPhone,
    required String parkingSlot,
    double? parkingFee,
    String? notes,
  }) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'vehicleNumber': vehicleNumber,
          'vehicleType': vehicleType,
          'ownerName': ownerName,
          'ownerPhone': ownerPhone,
          'parkingSlot': parkingSlot,
          'parkingFee': parkingFee ?? 0.0,
          'notes': notes,
        }),
      );

      print('Add Vehicle Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return VehicleModel.fromJson(data['vehicle']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add vehicle');
      }
    } catch (e) {
      print('Add Vehicle Error: $e');
      throw Exception('Failed to add vehicle: $e');
    }
  }

  // Get all vehicles
  Future<Map<String, dynamic>> getAllVehicles({
    String? status,
    String? vehicleType,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (vehicleType != null) queryParams['vehicleType'] = vehicleType;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get Vehicles Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final vehicles = (data['vehicles'] as List)
            .map((json) => VehicleModel.fromJson(json))
            .toList();

        return {
          'vehicles': vehicles,
          'pagination': data['pagination'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get vehicles');
      }
    } catch (e) {
      print('Get Vehicles Error: $e');
      throw Exception('Failed to get vehicles: $e');
    }
  }

  // Get vehicle by ID
  Future<VehicleModel> getVehicleById(String id) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get Vehicle Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VehicleModel.fromJson(data['vehicle']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get vehicle');
      }
    } catch (e) {
      print('Get Vehicle Error: $e');
      throw Exception('Failed to get vehicle: $e');
    }
  }

  // Update vehicle
  Future<VehicleModel> updateVehicle({
    required String id,
    String? vehicleNumber,
    String? vehicleType,
    String? ownerName,
    String? ownerPhone,
    String? parkingSlot,
    double? parkingFee,
    String? notes,
  }) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final body = <String, dynamic>{};
      if (vehicleNumber != null) body['vehicleNumber'] = vehicleNumber;
      if (vehicleType != null) body['vehicleType'] = vehicleType;
      if (ownerName != null) body['ownerName'] = ownerName;
      if (ownerPhone != null) body['ownerPhone'] = ownerPhone;
      if (parkingSlot != null) body['parkingSlot'] = parkingSlot;
      if (parkingFee != null) body['parkingFee'] = parkingFee;
      if (notes != null) body['notes'] = notes;

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Update Vehicle Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VehicleModel.fromJson(data['vehicle']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update vehicle');
      }
    } catch (e) {
      print('Update Vehicle Error: $e');
      throw Exception('Failed to update vehicle: $e');
    }
  }

  // Exit vehicle
  Future<VehicleModel> exitVehicle(String id) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$id/exit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Exit Vehicle Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VehicleModel.fromJson(data['vehicle']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to exit vehicle');
      }
    } catch (e) {
      print('Exit Vehicle Error: $e');
      throw Exception('Failed to exit vehicle: $e');
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(String id) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete Vehicle Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete vehicle');
      }
    } catch (e) {
      print('Delete Vehicle Error: $e');
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  // Get vehicle statistics
  Future<Map<String, dynamic>> getVehicleStats() async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Vehicle Stats Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['stats'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get vehicle stats');
      }
    } catch (e) {
      print('Vehicle Stats Error: $e');
      throw Exception('Failed to get vehicle stats: $e');
    }
  }

  // Get recent activities
  Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 10}) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/recent-activities?limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Recent Activities Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['activities']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get recent activities');
      }
    } catch (e) {
      print('Recent Activities Error: $e');
      throw Exception('Failed to get recent activities: $e');
    }
  }
}
