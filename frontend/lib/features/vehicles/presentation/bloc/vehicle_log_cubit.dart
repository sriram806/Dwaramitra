import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/vehicles/data/datasources/vehicle_log_repository.dart';
import 'package:frontend/features/vehicles/data/models/vehicle_log_model.dart';

// States
abstract class VehicleLogState {}

class VehicleLogInitial extends VehicleLogState {}

class VehicleLogLoading extends VehicleLogState {}

class VehicleLogLoaded extends VehicleLogState {
  final List<VehicleLogModel> logs;
  final int totalPages;
  final int currentPage;
  final int total;

  VehicleLogLoaded({
    required this.logs,
    required this.totalPages,
    required this.currentPage,
    required this.total,
  });
}

class VehicleLogError extends VehicleLogState {
  final String message;

  VehicleLogError(this.message);
}

class VehicleLogEntrySuccess extends VehicleLogState {
  final VehicleLogModel logEntry;

  VehicleLogEntrySuccess(this.logEntry);
}

class VehicleLogExitSuccess extends VehicleLogState {
  final VehicleLogModel logEntry;

  VehicleLogExitSuccess(this.logEntry);
}

class ParkedVehiclesLoaded extends VehicleLogState {
  final List<VehicleLogModel> parkedVehicles;

  ParkedVehiclesLoaded(this.parkedVehicles);
}

class DashboardStatsLoaded extends VehicleLogState {
  final Map<String, dynamic> stats;

  DashboardStatsLoaded(this.stats);
}

// Cubit
class VehicleLogCubit extends Cubit<VehicleLogState> {
  final VehicleLogRepository _repository = VehicleLogRepository();

  VehicleLogCubit() : super(VehicleLogInitial());

  // Log vehicle entry
  Future<void> logVehicleEntry({
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
    emit(VehicleLogLoading());
    try {
      final logEntry = await _repository.logVehicleEntry(
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
        ownerName: ownerName,
        ownerType: ownerType,
        contactNumber: contactNumber,
        universityId: universityId,
        department: department,
        purpose: purpose,
        entryGate: entryGate,
        entryShift: entryShift,
        notes: notes,
        expectedExitTime: expectedExitTime,
        isPreRegistered: isPreRegistered,
      );
      emit(VehicleLogEntrySuccess(logEntry));
    } catch (e) {
      emit(VehicleLogError(e.toString()));
    }
  }

  // Log vehicle exit
  Future<void> logVehicleExit({
    required String logId,
    String? exitGate,
    String? notes,
  }) async {
    emit(VehicleLogLoading());
    try {
      final logEntry = await _repository.logVehicleExit(
        logId: logId,
        exitGate: exitGate,
        notes: notes,
      );
      emit(VehicleLogExitSuccess(logEntry));
    } catch (e) {
      emit(VehicleLogError(e.toString()));
    }
  }

  // Get vehicle logs with filtering
  Future<void> getVehicleLogs({
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
    emit(VehicleLogLoading());
    try {
      final result = await _repository.getVehicleLogs(
        status: status,
        startDate: startDate,
        endDate: endDate,
        vehicleNumber: vehicleNumber,
        ownerType: ownerType,
        entryGate: entryGate,
        entryShift: entryShift,
        page: page,
        limit: limit,
      );

      emit(VehicleLogLoaded(
        logs: result['logs'],
        totalPages: result['totalPages'],
        currentPage: result['page'],
        total: result['total'],
      ));
    } catch (e) {
      emit(VehicleLogError(e.toString()));
    }
  }

  // Get parked vehicles
  Future<void> getParkedVehicles({
    String? entryGate,
    String? ownerType,
  }) async {
    emit(VehicleLogLoading());
    try {
      final parkedVehicles = await _repository.getParkedVehicles(
        entryGate: entryGate,
        ownerType: ownerType,
      );
      emit(ParkedVehiclesLoaded(parkedVehicles));
    } catch (e) {
      emit(VehicleLogError(e.toString()));
    }
  }

  // Get dashboard stats
  Future<void> getDashboardStats() async {
    emit(VehicleLogLoading());
    try {
      final stats = await _repository.getDashboardStats();
      emit(DashboardStatsLoaded(stats));
    } catch (e) {
      emit(VehicleLogError(e.toString()));
    }
  }

  // Get logs by guard
  Future<void> getLogsByGuard({
    required String guardId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    emit(VehicleLogLoading());
    try {
      final result = await _repository.getLogsByGuard(
        guardId: guardId,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );

      emit(VehicleLogLoaded(
        logs: result['logs'],
        totalPages: result['totalPages'],
        currentPage: result['page'],
        total: result['total'],
      ));
    } catch (e) {
      emit(VehicleLogError(e.toString()));
    }
  }

  // Get logs by gate
  Future<void> getLogsByGate({
    required String gate,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    emit(VehicleLogLoading());
    try {
      final result = await _repository.getLogsByGate(
        gate: gate,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );

      emit(VehicleLogLoaded(
        logs: result['logs'],
        totalPages: result['totalPages'],
        currentPage: result['page'],
        total: result['total'],
      ));
    } catch (e) {
      emit(VehicleLogError(e.toString()));
    }
  }

  // Export logs to CSV
  Future<String?> exportLogsToCSV({
    String? startDate,
    String? endDate,
    String? status,
    String? ownerType,
    String? entryGate,
  }) async {
    try {
      return await _repository.exportLogsToCSV(
        startDate: startDate,
        endDate: endDate,
        status: status,
        ownerType: ownerType,
        entryGate: entryGate,
      );
    } catch (e) {
      emit(VehicleLogError(e.toString()));
      return null;
    }
  }

  // Assign guard to gate
  Future<void> assignGuardToGate({
    required String guardId,
    required String gate,
    required String shift,
    String? startDate,
    String? endDate,
  }) async {
    emit(VehicleLogLoading());
    try {
      await _repository.assignGuardToGate(
        guardId: guardId,
        gate: gate,
        shift: shift,
        startDate: startDate,
        endDate: endDate,
      );
      // Optionally reload data or emit success state
    } catch (e) {
      emit(VehicleLogError(e.toString()));
    }
  }

  // Reset state
  void reset() {
    emit(VehicleLogInitial());
  }
}