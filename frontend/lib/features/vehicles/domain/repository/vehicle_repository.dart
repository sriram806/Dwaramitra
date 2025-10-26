import 'package:frontend/features/vehicles/domain/entities/vehicle.dart';

abstract class VehicleRepository {
  Future<Vehicle> addVehicle({
    required String vehicleNumber,
    required String vehicleType,
    required String ownerName,
    required String ownerPhone,
    required String parkingSlot,
    double? parkingFee,
    String? notes,
  });

  Future<Map<String, dynamic>> getAllVehicles({
    String? status,
    String? vehicleType,
    String? search,
    int page = 1,
    int limit = 20,
  });

  Future<Vehicle> getVehicleById(String id);

  Future<Vehicle> updateVehicle({
    required String id,
    String? vehicleNumber,
    String? vehicleType,
    String? ownerName,
    String? ownerPhone,
    String? parkingSlot,
    double? parkingFee,
    String? notes,
  });

  Future<Vehicle> exitVehicle(String id);

  Future<void> deleteVehicle(String id);

  Future<Map<String, dynamic>> getVehicleStats();

  Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 10});
}