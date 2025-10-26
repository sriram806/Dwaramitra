import 'package:frontend/features/vehicles/domain/entities/vehicle.dart';

class VehicleLog {
  final String? id;
  final Vehicle? vehicle;
  final String vehicleNumber;
  final String ownerType;
  final String purpose;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String status;
  final String? entryGate;
  final String? entryShift;
  final Map<String, dynamic>? entryGuard;
  final Map<String, dynamic>? exitGuard;
  final String? entryBy;
  final String? exitBy;

  const VehicleLog({
    this.id,
    this.vehicle,
    required this.vehicleNumber,
    required this.ownerType,
    required this.purpose,
    required this.entryTime,
    this.exitTime,
    required this.status,
    this.entryGate,
    this.entryShift,
    this.entryGuard,
    this.exitGuard,
    this.entryBy,
    this.exitBy,
  });

  VehicleLog copyWith({
    String? id,
    Vehicle? vehicle,
    String? vehicleNumber,
    String? ownerType,
    String? purpose,
    DateTime? entryTime,
    DateTime? exitTime,
    String? status,
    String? entryGate,
    String? entryShift,
    Map<String, dynamic>? entryGuard,
    Map<String, dynamic>? exitGuard,
    String? entryBy,
    String? exitBy,
  }) {
    return VehicleLog(
      id: id ?? this.id,
      vehicle: vehicle ?? this.vehicle,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      ownerType: ownerType ?? this.ownerType,
      purpose: purpose ?? this.purpose,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      status: status ?? this.status,
      entryGate: entryGate ?? this.entryGate,
      entryShift: entryShift ?? this.entryShift,
      entryGuard: entryGuard ?? this.entryGuard,
      exitGuard: exitGuard ?? this.exitGuard,
      entryBy: entryBy ?? this.entryBy,
      exitBy: exitBy ?? this.exitBy,
    );
  }

  @override
  String toString() {
    return 'VehicleLog(id: $id, vehicleNumber: $vehicleNumber, status: $status, entryTime: $entryTime)';
  }
}