import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/vehicles/repository/vehicle_repository.dart';
import 'package:frontend/models/vehicle_model.dart';

part 'vehicle_state.dart';

class VehicleCubit extends Cubit<VehicleState> {
  final VehicleRepository _repository = VehicleRepository();

  VehicleCubit() : super(VehicleInitial());

  // Load all vehicles
  Future<void> loadVehicles({
    String? status,
    String? vehicleType,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      emit(VehicleLoading());
      
      final result = await _repository.getAllVehicles(
        status: status,
        vehicleType: vehicleType,
        search: search,
        page: page,
        limit: limit,
      );

      emit(VehicleLoaded(
        result['vehicles'] as List<VehicleModel>,
        pagination: result['pagination'],
      ));
    } catch (e) {
      emit(VehicleError(e.toString()));
      _showErrorToast(e.toString());
    }
  }

  // Add new vehicle
  Future<void> addVehicle({
    required String vehicleNumber,
    required String vehicleType,
    required String ownerName,
    required String ownerPhone,
    required String parkingSlot,
    double? parkingFee,
    String? notes,
  }) async {
    try {
      emit(VehicleAdding());
      
      final vehicle = await _repository.addVehicle(
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        parkingSlot: parkingSlot,
        parkingFee: parkingFee,
        notes: notes,
      );

      emit(VehicleOperationSuccess('Vehicle added successfully!', vehicle: vehicle));
      _showSuccessToast('Vehicle added successfully!');
      
      // Reload vehicles list
      await loadVehicles();
    } catch (e) {
      emit(VehicleError(e.toString()));
      _showErrorToast(e.toString());
    }
  }

  // Update vehicle
  Future<void> updateVehicle({
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
      emit(VehicleUpdating());
      
      final vehicle = await _repository.updateVehicle(
        id: id,
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        parkingSlot: parkingSlot,
        parkingFee: parkingFee,
        notes: notes,
      );

      emit(VehicleOperationSuccess('Vehicle updated successfully!', vehicle: vehicle));
      _showSuccessToast('Vehicle updated successfully!');
      
      // Reload vehicles list
      await loadVehicles();
    } catch (e) {
      emit(VehicleError(e.toString()));
      _showErrorToast(e.toString());
    }
  }

  // Exit vehicle
  Future<void> exitVehicle(String id) async {
    try {
      emit(VehicleExiting());
      
      final vehicle = await _repository.exitVehicle(id);

      emit(VehicleOperationSuccess('Vehicle exited successfully!', vehicle: vehicle));
      _showSuccessToast('Vehicle exited successfully!');
      
      // Reload vehicles list
      await loadVehicles();
    } catch (e) {
      emit(VehicleError(e.toString()));
      _showErrorToast(e.toString());
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(String id) async {
    try {
      emit(VehicleDeleting());
      
      await _repository.deleteVehicle(id);

      emit(VehicleOperationSuccess('Vehicle deleted successfully!'));
      _showSuccessToast('Vehicle deleted successfully!');
      
      // Reload vehicles list
      await loadVehicles();
    } catch (e) {
      emit(VehicleError(e.toString()));
      _showErrorToast(e.toString());
    }
  }

  // Load vehicle statistics
  Future<void> loadVehicleStats() async {
    try {
      emit(VehicleLoading());
      
      final stats = await _repository.getVehicleStats();
      
      emit(VehicleStatsLoaded(stats));
    } catch (e) {
      emit(VehicleError(e.toString()));
      _showErrorToast(e.toString());
    }
  }

  // Load recent activities
  Future<void> loadRecentActivities({int limit = 10}) async {
    try {
      final activities = await _repository.getRecentActivities(limit: limit);
      
      emit(VehicleActivitiesLoaded(activities));
    } catch (e) {
      emit(VehicleError(e.toString()));
      _showErrorToast(e.toString());
    }
  }

  // Get vehicle by ID
  Future<VehicleModel?> getVehicleById(String id) async {
    try {
      return await _repository.getVehicleById(id);
    } catch (e) {
      _showErrorToast(e.toString());
      return null;
    }
  }

  // Search vehicles
  Future<void> searchVehicles(String query) async {
    await loadVehicles(search: query);
  }

  // Filter vehicles by status
  Future<void> filterByStatus(String status) async {
    await loadVehicles(status: status);
  }

  // Filter vehicles by type
  Future<void> filterByType(String vehicleType) async {
    await loadVehicles(vehicleType: vehicleType);
  }

  // Load more vehicles (pagination)
  Future<void> loadMoreVehicles({
    String? status,
    String? vehicleType,
    String? search,
    required int page,
    int limit = 20,
  }) async {
    try {
      final result = await _repository.getAllVehicles(
        status: status,
        vehicleType: vehicleType,
        search: search,
        page: page,
        limit: limit,
      );

      // If current state is VehicleLoaded, append new vehicles
      if (state is VehicleLoaded) {
        final currentState = state as VehicleLoaded;
        final allVehicles = [...currentState.vehicles, ...result['vehicles'] as List<VehicleModel>];
        
        emit(VehicleLoaded(
          allVehicles,
          pagination: result['pagination'],
        ));
      } else {
        emit(VehicleLoaded(
          result['vehicles'] as List<VehicleModel>,
          pagination: result['pagination'],
        ));
      }
    } catch (e) {
      emit(VehicleError(e.toString()));
      _showErrorToast(e.toString());
    }
  }

  // Clear filters
  Future<void> clearFilters() async {
    await loadVehicles();
  }

  // Helper methods for toast notifications
  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }


}