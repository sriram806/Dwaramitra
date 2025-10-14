import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/vehicles/cubit/vehicle_cubit.dart';
import 'package:frontend/features/vehicles/pages/add_vehicle_page.dart';
import 'package:frontend/features/vehicles/pages/edit_vehicle_page.dart';
import 'package:frontend/features/vehicles/pages/vehicle_details_page.dart';
import 'package:frontend/models/vehicle_model.dart';
import 'package:frontend/core/widgets/role_based_widget.dart';


class VehicleManagementPage extends StatefulWidget {
  const VehicleManagementPage({super.key});

  @override
  State<VehicleManagementPage> createState() => _VehicleManagementPageState();
}

class _VehicleManagementPageState extends State<VehicleManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<VehicleCubit>().loadVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Vehicles',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        actions: [
          RoleBasedWidget(
            requiredPermission: 'manage_vehicles',
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddVehiclePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: 'Add Vehicle',
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Search and Filter Section
          Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black87),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        context.read<VehicleCubit>().clearFilters();
                      } else {
                        context.read<VehicleCubit>().searchVehicles(value);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search vehicles by number, owner...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                context.read<VehicleCubit>().clearFilters();
                              },
                              icon: Icon(Icons.clear, color: Colors.grey.shade400),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Modern Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildModernFilterChip(
                        'All Status',
                        _selectedStatus == null,
                        () {
                          setState(() {
                            _selectedStatus = null;
                          });
                          context.read<VehicleCubit>().clearFilters();
                        },
                        Icons.list_alt,
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildModernFilterChip(
                        'Parked',
                        _selectedStatus == 'parked',
                        () {
                          setState(() {
                            _selectedStatus = 'parked';
                          });
                          context.read<VehicleCubit>().filterByStatus('parked');
                        },
                        Icons.local_parking,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildModernFilterChip(
                        'Exited',
                        _selectedStatus == 'exited',
                        () {
                          setState(() {
                            _selectedStatus = 'exited';
                          });
                          context.read<VehicleCubit>().filterByStatus('exited');
                        },
                        Icons.exit_to_app,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Vehicles List
          Expanded(
            child: BlocBuilder<VehicleCubit, VehicleState>(
              builder: (context, state) {
                if (state is VehicleLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is VehicleLoaded) {
                  if (state.vehicles.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildVehiclesList(state.vehicles);
                } else if (state is VehicleError) {
                  return _buildErrorState(state.message);
                }
                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: RoleBasedWidget(
        requiredPermission: 'manage_vehicles',
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddVehiclePage(),
              ),
            );
          },
          backgroundColor: const Color(0xFF4285F4),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildModernFilterChip(
    String label, 
    bool isSelected, 
    VoidCallback onTap, 
    IconData icon, 
    Color color
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesList(List<VehicleModel> vehicles) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<VehicleCubit>().loadVehicles();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return _buildVehicleCard(vehicle);
        },
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailsPage(vehicle: vehicle),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getVehicleIcon(vehicle.vehicleType),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Vehicle Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.vehicleNumber,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          vehicle.ownerName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicle.vehicleType,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(vehicle.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vehicle.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Info Row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_on,
                      'Gate',
                      vehicle.gateName,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.access_time,
                      'Duration',
                      '${vehicle.duration}h',
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.phone,
                      'Contact',
                      vehicle.contactNumber,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (vehicle.status == 'parked') ...[
                    _buildActionButton(
                      'Exit',
                      Icons.exit_to_app,
                      Colors.orange,
                      () => _showExitConfirmation(vehicle),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _buildActionButton(
                    'Edit',
                    Icons.edit,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditVehiclePage(vehicle: vehicle),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    'Delete',
                    Icons.delete,
                    Colors.red,
                    () => _showDeleteConfirmation(vehicle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No vehicles found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new vehicle to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddVehiclePage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Vehicle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<VehicleCubit>().loadVehicles();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bike':
      case 'motorcycle':
        return Icons.motorcycle;
      case 'truck':
        return Icons.local_shipping;
      case 'bus':
        return Icons.directions_bus;
      default:
        return Icons.directions_car;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'parked':
        return Colors.green;
      case 'exited':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showExitConfirmation(VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Vehicle'),
          content: Text('Are you sure you want to exit ${vehicle.vehicleNumber}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<VehicleCubit>().exitVehicle(vehicle.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: Text(
            'Are you sure you want to delete ${vehicle.vehicleNumber}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<VehicleCubit>().deleteVehicle(vehicle.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}