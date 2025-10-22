import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/vehicles/cubit/vehicle_cubit.dart';
import 'package:frontend/features/vehicles/pages/edit_vehicle_page.dart';
import 'package:frontend/models/vehicle_model.dart';
import 'package:intl/intl.dart';

class VehicleDetailsPage extends StatelessWidget {
  final VehicleModel vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          vehicle.plateNumber,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4285F4),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditVehiclePage(vehicle: vehicle),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Vehicle',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF4285F4),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      _getVehicleTypeIcon(vehicle.vehicleType),
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      vehicle.plateNumber,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: vehicle.status == 'parked' ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        vehicle.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Vehicle Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildInfoSection(context, 'Vehicle Information', [
                    _buildInfoTile(
                      Icons.confirmation_number,
                      'Plate Number',
                      vehicle.plateNumber,
                    ),
                    _buildInfoTile(
                      Icons.directions_car,
                      'Vehicle Type',
                      vehicle.vehicleType.toUpperCase(),
                    ),
                    _buildInfoTile(
                      Icons.location_on,
                      'Gate Name',
                      vehicle.gateName,
                    ),
                    _buildInfoTile(
                      Icons.person,
                      'Owner Role',
                      vehicle.ownerRole,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Owner Information
                  _buildInfoSection(context, 'Owner Information', [
                    _buildInfoTile(
                      Icons.person,
                      'Owner Name',
                      vehicle.ownerName,
                    ),
                    _buildInfoTile(
                      Icons.phone,
                      'Contact Number',
                      vehicle.contactNumber,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Timing Information
                  _buildInfoSection(context, 'Timing Information', [
                    _buildInfoTile(
                      Icons.login,
                      'Entry Time',
                      _formatDateTime(vehicle.entryTime),
                    ),
                    if (vehicle.exitTime != null)
                      _buildInfoTile(
                        Icons.logout,
                        'Exit Time',
                        _formatDateTime(vehicle.exitTime!),
                      ),
                    _buildInfoTile(
                      Icons.timer,
                      'Duration',
                      vehicle.formattedDuration,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // System Information
                  _buildInfoSection(context, 'System Information', [
                    _buildInfoTile(
                      Icons.calendar_today,
                      'Created At',
                      _formatDateTime(vehicle.createdAt),
                    ),
                    _buildInfoTile(
                      Icons.update,
                      'Last Updated',
                      _formatDateTime(vehicle.updatedAt),
                    ),
                  ]),

                  const SizedBox(height: 30),

                  // Action Buttons
                  if (vehicle.status == 'parked') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showExitConfirmation(context);
                        },
                        icon: const Icon(Icons.exit_to_app, color: Colors.white),
                        label: const Text(
                          'Exit Vehicle',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditVehiclePage(vehicle: vehicle),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4285F4),
                            side: const BorderSide(color: Color(0xFF4285F4)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showDeleteConfirmation(context);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4285F4),
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4285F4), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getVehicleTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'car':
        return '🚗';
      case 'bike':
        return '🏍️';
      case 'truck':
        return '🚛';
      case 'bus':
        return '🚌';
      default:
        return '🚗';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Vehicle'),
          content: Text('Are you sure you want to exit ${vehicle.plateNumber}?'),
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
                Navigator.of(context).pop(); // Go back to previous screen
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: Text(
            'Are you sure you want to delete ${vehicle.plateNumber}? This action cannot be undone.',
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
                Navigator.of(context).pop(); // Go back to previous screen
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
