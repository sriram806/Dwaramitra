import 'package:frontend/features/vehicles/domain/entities/vehicle_log.dart';
import 'package:frontend/features/vehicles/domain/repository/vehicle_log_repository.dart';

class LogVehicleEntryUseCase {
  final VehicleLogRepository repository;

  LogVehicleEntryUseCase(this.repository);

  Future<VehicleLog> call({
    required String vehicleNumber,
    required String vehicleType,
    required String ownerName,
    required String contactNumber,
    required String ownerType,
    required String purpose,
    String? entryGate,
    String? entryShift,
    String? guardId,
    String? guardName,
  }) {
    return repository.logVehicleEntry(
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      ownerName: ownerName,
      contactNumber: contactNumber,
      ownerType: ownerType,
      purpose: purpose,
      entryGate: entryGate,
      entryShift: entryShift,
      guardId: guardId,
      guardName: guardName,
    );
  }
}