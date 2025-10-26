part of 'vehicle_cubit.dart';

abstract class VehicleState {}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<VehicleModel> vehicles;
  final Map<String, dynamic>? pagination;

  VehicleLoaded(this.vehicles, {this.pagination});
}

class VehicleStatsLoaded extends VehicleState {
  final Map<String, dynamic> stats;

  VehicleStatsLoaded(this.stats);
}

class VehicleActivitiesLoaded extends VehicleState {
  final List<Map<String, dynamic>> activities;

  VehicleActivitiesLoaded(this.activities);
}

class VehicleOperationSuccess extends VehicleState {
  final String message;
  final VehicleModel? vehicle;

  VehicleOperationSuccess(this.message, {this.vehicle});
}

class VehicleError extends VehicleState {
  final String message;

  VehicleError(this.message);
}

class VehicleAdding extends VehicleState {}

class VehicleUpdating extends VehicleState {}

class VehicleExiting extends VehicleState {}

class VehicleDeleting extends VehicleState {}
