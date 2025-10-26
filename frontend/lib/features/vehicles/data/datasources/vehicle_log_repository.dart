import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/vehicles/data/models/vehicle_log_model.dart';

class VehicleLogRepository {
  final SpService _spService = SpService();
  
  String get baseUrl => '${Constants.backendUri}/vehicle-logs';

  Future<VehicleLogModel> logVehicleEntry({
    required String vehicleNumber,
    required String vehicleType,
    required String ownerName,
    required String ownerType,
    required String contactNumber,
    String? universityId,
    String? department,
    String? purpose,
    String? entryGate,
    String? entryShift,
    String? notes,
    DateTime? expectedExitTime,
    bool isPreRegistered = false,
  }) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final body = <String, dynamic>{
        'vehicleNumber': vehicleNumber,
        'vehicleType': vehicleType,
        'ownerName': ownerName,
        'ownerType': ownerType,
        'contactNumber': contactNumber,
        'entryGate': entryGate ?? 'GATE 1',
        'entryShift': entryShift ?? 'Day Shift',
        'isPreRegistered': isPreRegistered,
      };

      // Add optional fields
      if (universityId != null) body['universityId'] = universityId;
      if (department != null) body['department'] = department;
      if (purpose != null) body['purpose'] = purpose;
      if (notes != null) body['notes'] = notes;
      if (expectedExitTime != null) body['expectedExitTime'] = expectedExitTime.toIso8601String();

      final response = await http.post(
        Uri.parse('$baseUrl/entry'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return VehicleLogModel.fromMap(data['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to log vehicle entry');
      }
    } catch (e) {
      throw Exception('Failed to log vehicle entry: $e');
    }
  }

  // Log vehicle exit
  Future<VehicleLogModel> logVehicleExit({
    required String logId,
    String? exitGate,
    String? notes,
  }) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Server expects PUT /exit/:logId and uses authenticated user as exit guard
      final Map<String, dynamic> body = {};
      if (exitGate != null) body['exitGate'] = exitGate;
      if (notes != null) body['notes'] = notes;

      final response = await http.put(
        Uri.parse('$baseUrl/exit/$logId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VehicleLogModel.fromMap(data['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to log vehicle exit');
      }
    } catch (e) {
      throw Exception('Failed to log vehicle exit: $e');
    }
  }

  // Get all vehicle logs with filtering
  Future<Map<String, dynamic>> getVehicleLogs({
    String? status,
    String? startDate,
    String? endDate,
    String? vehicleNumber,
    String? ownerType,
    String? entryGate,
    String? entryShift,
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
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (vehicleNumber != null) queryParams['vehicleNumber'] = vehicleNumber;
      if (ownerType != null) queryParams['ownerType'] = ownerType;
      if (entryGate != null) queryParams['entryGate'] = entryGate;
      if (entryShift != null) queryParams['entryShift'] = entryShift;

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final logs = (data['data'] as List)
            .map((json) => VehicleLogModel.fromMap(json))
            .toList();

        return {
          'logs': logs,
          'count': data['count'],
          'total': data['total'],
          'page': data['page'],
          'totalPages': data['totalPages'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get vehicle logs');
      }
    } catch (e) {
      throw Exception('Failed to get vehicle logs: $e');
    }
  }

  // Get parked vehicles
  Future<List<VehicleLogModel>> getParkedVehicles({
    String? entryGate,
    String? ownerType,
  }) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (entryGate != null) queryParams['entryGate'] = entryGate;
      if (ownerType != null) queryParams['ownerType'] = ownerType;

      final uri = Uri.parse('$baseUrl/parked').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((json) => VehicleLogModel.fromMap(json))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get parked vehicles');
      }
    } catch (e) {
      throw Exception('Failed to get parked vehicles: $e');
    }
  }

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        // Server exposes stats at /stats
        Uri.parse('$baseUrl/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get dashboard stats');
      }
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  // Get log by ID
  Future<VehicleLogModel> getLogById(String id) async {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VehicleLogModel.fromMap(data['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get log');
      }
    } catch (e) {
      throw Exception('Failed to get log: $e');
    }
  }

  // Get logs by guard
  Future<Map<String, dynamic>> getLogsByGuard({
    required String guardId,
    String? startDate,
    String? endDate,
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

      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

  // Server reporting endpoint: /report/guard/:guardId
  final uri = Uri.parse('$baseUrl/report/guard/$guardId').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final logs = (data['data'] as List)
            .map((json) => VehicleLogModel.fromMap(json))
            .toList();

        return {
          'logs': logs,
          'count': data['count'],
          'total': data['total'],
          'page': data['page'],
          'totalPages': data['totalPages'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get logs by guard');
      }
    } catch (e) {
      throw Exception('Failed to get logs by guard: $e');
    }
  }

  // Get logs by gate
  Future<Map<String, dynamic>> getLogsByGate({
    required String gate,
    String? startDate,
    String? endDate,
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

      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

  // Server reporting endpoint: /report/gate/:gate
  final uri = Uri.parse('$baseUrl/report/gate/$gate').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final logs = (data['data'] as List)
            .map((json) => VehicleLogModel.fromMap(json))
            .toList();

        return {
          'logs': logs,
          'count': data['count'],
          'total': data['total'],
          'page': data['page'],
          'totalPages': data['totalPages'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get logs by gate');
      }
    } catch (e) {
      throw Exception('Failed to get logs by gate: $e');
    }
  }

  // Export logs to CSV
  Future<String> exportLogsToCSV({
    String? startDate,
    String? endDate,
    String? status,
    String? ownerType,
    String? entryGate,
  }) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (status != null) queryParams['status'] = status;
      if (ownerType != null) queryParams['ownerType'] = ownerType;
      if (entryGate != null) queryParams['entryGate'] = entryGate;

  final uri = Uri.parse('$baseUrl/export/csv').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.body; // Returns CSV content
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to export logs');
      }
    } catch (e) {
      throw Exception('Failed to export logs: $e');
    }
  }

  // Assign guard to gate
  Future<Map<String, dynamic>> assignGuardToGate({
    required String guardId,
    required String gate,
    required String shift,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await _spService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Server assigns guard via /assign-guard
      final response = await http.post(
        Uri.parse('$baseUrl/assign-guard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'guardId': guardId,
          'gate': gate,
          'shift': shift,
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to assign guard');
      }
    } catch (e) {
      throw Exception('Failed to assign guard: $e');
    }
  }
}