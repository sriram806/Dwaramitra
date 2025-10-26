import 'dart:convert';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/vehicles/data/models/vehicle_model.dart';
import 'package:http/http.dart' as http;

class VehicleRemoteRepository {
  final spService = SpService();

  Future<VehicleModel> addVehicle({
    required String vehicleNumber,
    required String vehicleType,
    required String ownerName,
    required String ownerRole,
    String? universityId,
    String? department,
    required String contactNumber,
    required String gateName,
    String? purpose,
    String? notes,
  }) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/vehicle/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'vehicleNumber': vehicleNumber,
          'vehicleType': vehicleType,
          'ownerName': ownerName,
          'ownerRole': ownerRole,
          'universityId': universityId,
          'department': department,
          'contactNumber': contactNumber,
          'gateName': gateName,
          'purpose': purpose,
          'notes': notes,
        }),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 201) {
        throw body['message'] ?? 'Failed to add vehicle';
      }
      
      return VehicleModel.fromMap(body['vehicle']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<VehicleModel>> getAllVehicles({
    String? status,
    String? vehicleType,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (vehicleType != null) queryParams['vehicleType'] = vehicleType;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('${Constants.backendUri}/vehicle').replace(queryParameters: queryParams);

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to get vehicles';
      }
      
      final List<dynamic> vehiclesData = body['vehicles'] ?? [];
      return vehiclesData.map((v) => VehicleModel.fromMap(v)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<VehicleModel> getVehicleById(String vehicleId) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final res = await http.get(
        Uri.parse('${Constants.backendUri}/vehicle/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to get vehicle';
      }
      
      return VehicleModel.fromMap(body['vehicle']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<VehicleModel> updateVehicle({
    required String vehicleId,
    String? vehicleNumber,
    String? vehicleType,
    String? ownerName,
    String? ownerRole,
    String? universityId,
    String? department,
    String? contactNumber,
    String? gateName,
    String? purpose,
    String? notes,
  }) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final Map<String, dynamic> requestBody = {};
      if (vehicleNumber != null) requestBody['vehicleNumber'] = vehicleNumber;
      if (vehicleType != null) requestBody['vehicleType'] = vehicleType;
      if (ownerName != null) requestBody['ownerName'] = ownerName;
      if (ownerRole != null) requestBody['ownerRole'] = ownerRole;
      if (universityId != null) requestBody['universityId'] = universityId;
      if (department != null) requestBody['department'] = department;
      if (contactNumber != null) requestBody['contactNumber'] = contactNumber;
      if (gateName != null) requestBody['gateName'] = gateName;
      if (purpose != null) requestBody['purpose'] = purpose;
      if (notes != null) requestBody['notes'] = notes;

      final res = await http.put(
        Uri.parse('${Constants.backendUri}/vehicle/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to update vehicle';
      }
      
      return VehicleModel.fromMap(body['vehicle']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final res = await http.delete(
        Uri.parse('${Constants.backendUri}/vehicle/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to delete vehicle';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<VehicleModel> exitVehicle(String vehicleId) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/vehicle/$vehicleId/exit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to exit vehicle';
      }
      
      return VehicleModel.fromMap(body['vehicle']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getVehicleStats() async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final res = await http.get(
        Uri.parse('${Constants.backendUri}/vehicle/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to get vehicle stats';
      }
      
      return body['stats'] ?? {};
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<VehicleModel>> getRecentActivities() async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No authentication token found';
      }

      final res = await http.get(
        Uri.parse('${Constants.backendUri}/vehicle/recent-activities'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode != 200) {
        throw body['message'] ?? 'Failed to get recent activities';
      }
      
      final List<dynamic> activitiesData = body['activities'] ?? [];
      return activitiesData.map((v) => VehicleModel.fromMap(v)).toList();
    } catch (e) {
      throw e.toString();
    }
  }
}
