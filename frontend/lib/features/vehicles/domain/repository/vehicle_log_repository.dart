import 'package:frontend/features/vehicles/domain/entities/vehicle_log.dart';

abstract class VehicleLogRepository {
  Future<VehicleLog> logVehicleEntry({
    required String vehicleNumber,
    required String vehicleType,
    required String ownerName,
    required String ownerType,
    required String contactNumber,
    required String purpose,
    String? entryGate,
    String? entryShift,
    String? guardId,
    String? guardName,
  });

  Future<VehicleLog> logVehicleExit({
    required String logId,
    String? exitGuardId,
    String? exitGuardName,
    String? exitGate,
  });

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
  });

  Future<List<VehicleLog>> getParkedVehicles({
    String? entryGate,
    String? ownerType,
  });

  Future<Map<String, dynamic>> getDashboardStats();

  Future<VehicleLog> getLogById(String id);

  Future<Map<String, dynamic>> getLogsByGuard({
    required String guardId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<Map<String, dynamic>> getLogsByGate({
    required String gate,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<String> exportLogsToCSV({
    String? startDate,
    String? endDate,
    String? status,
    String? ownerType,
    String? entryGate,
  });

  Future<Map<String, dynamic>> assignGuardToGate({
    required String guardId,
    required String gate,
    required String shift,
    String? startDate,
    String? endDate,
  });
}