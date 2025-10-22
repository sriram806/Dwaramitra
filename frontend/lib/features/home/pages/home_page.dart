import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend/features/vehicles/pages/vehicle_management_page.dart';
import 'package:frontend/features/vehicles/pages/add_vehicle_page.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/vehicle_model.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const HomePage(),
      );
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? currentUser;
  List<VehicleModel> vehicles = [];
  List<VehicleModel> filteredVehicles = [];
  String selectedFilter = 'all'; // 'all', 'parked', 'exited'
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Show the page immediately, then load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSampleDataAsync();
    });
  }

  void _loadSampleDataAsync() async {
    // Small delay to ensure UI renders first
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (mounted) {
      // Load sample data here (keeping original logic)
      _loadSampleData();
      setState(() {
        isLoadingData = false;
      });
    }
  }

  void _loadUserData() {
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthLoggedIn) {
        currentUser = authState.user;
        // Use setState only if mounted to avoid unnecessary rebuilds
        if (mounted) {
          setState(() {});
        }
      } else if (authState is AuthOtpVerified) {
        currentUser = authState.user;
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _loadSampleData() {
    // Sample vehicle data for demonstration
    vehicles = [
      VehicleModel(
        id: '1',
        vehicleNumber: 'ABC-123',
        vehicleType: 'four-wheeler',
        ownerName: 'John Doe',
        ownerRole: 'student',
        universityId: 'STU001',
        department: 'Computer Science',
        contactNumber: '+1234567890',
        entryTime: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'inside',
        gateName: 'Main Gate',
        duration: 120, // 2 hours in minutes
        purpose: 'Academic',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      VehicleModel(
        id: '2',
        vehicleNumber: 'XYZ-789',
        vehicleType: 'two-wheeler',
        ownerName: 'Jane Smith',
        ownerRole: 'faculty',
        universityId: 'FAC002',
        department: 'Mathematics',
        contactNumber: '+1987654321',
        entryTime: DateTime.now().subtract(const Duration(hours: 4)),
        exitTime: DateTime.now().subtract(const Duration(hours: 1)),
        status: 'exited',
        gateName: 'Side Gate',
        duration: 180, // 3 hours in minutes
        purpose: 'Work',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      VehicleModel(
        id: '3',
        vehicleNumber: 'DEF-456',
        vehicleType: 'four-wheeler',
        ownerName: 'Mike Johnson',
        ownerRole: 'staff',
        universityId: 'STF003',
        department: 'Administration',
        contactNumber: '+1122334455',
        entryTime: DateTime.now().subtract(const Duration(minutes: 30)),
        status: 'inside',
        gateName: 'Main Gate',
        duration: 30,
        purpose: 'Official',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      switch (selectedFilter) {
        case 'parked':
          filteredVehicles = vehicles.where((v) => v.isParked).toList();
          break;
        case 'exited':
          filteredVehicles = vehicles.where((v) => v.hasExited).toList();
          break;
        default:
          filteredVehicles = List.from(vehicles);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vehicle Manager'),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, ProfilePage.route());
              },
              icon: const Icon(Icons.person),
              tooltip: 'Profile',
            ),
          ],
        ),
        body: currentUser == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading dashboard...'),
                  ],
                ),
              )
            : isLoadingData
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading vehicle data...'),
                      ],
                    ),
                  )
                : Column(
                children: [
                  // Dashboard Stats
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Parking Overview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard('Total', '${vehicles.length}', Icons.directions_car),
                            _buildStatCard('Parked', '${vehicles.where((v) => v.isParked).length}', Icons.local_parking),
                            _buildStatCard('Exited', '${vehicles.where((v) => v.hasExited).length}', Icons.exit_to_app),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Filter Tabs
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Parked', 'parked'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Exited', 'exited'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Role-based Quick Actions
                  _buildRoleBasedActions(),
                  const SizedBox(height: 16),

                  // Vehicle List Header
                  Expanded(
                    child: filteredVehicles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No vehicles found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredVehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = filteredVehicles[index];
                              return _buildVehicleCard(vehicle);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
        });
        _applyFilter();
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: vehicle.isParked ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vehicle.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  vehicle.plateNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(vehicle.ownerName, style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Icon(
                  vehicle.vehicleType == 'Car' ? Icons.directions_car : Icons.motorcycle,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(vehicle.vehicleType),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Entry: ${DateFormat('MMM dd, HH:mm').format(vehicle.entryTime)}',
                ),
              ],
            ),
            if (vehicle.exitTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.exit_to_app, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Exit: ${DateFormat('MMM dd, HH:mm').format(vehicle.exitTime!)}',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text('Duration: ${vehicle.formattedDuration}'),
                  const Spacer(),
                  Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(vehicle.gateName),
                ],
              ),
              if (vehicle.isInside) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showExitVehicleDialog(vehicle),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Mark Exit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }



  void _showExitVehicleDialog(VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Vehicle Exit'),
        content: Text('Mark ${vehicle.plateNumber} as exited?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markVehicleExit(vehicle);
            },
            child: const Text('Mark Exit'),
          ),
        ],
      ),
    );
  }

  void _markVehicleExit(VehicleModel vehicle) {
    setState(() {
      final index = vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        vehicles[index] = vehicle.copyWith(
          status: 'exited',
          exitTime: DateTime.now(),
          duration: DateTime.now().difference(vehicle.entryTime).inMinutes,
          updatedAt: DateTime.now(),
        );
      }
    });
    _applyFilter();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vehicle.plateNumber} marked as exited'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildRoleBasedActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Add Vehicle
              Expanded(
                child: _buildActionCard(
                  'Add Vehicle',
                  Icons.add_circle,
                  Colors.green,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddVehiclePage())),
                ),
              ),
              const SizedBox(width: 12),
              
              // Vehicle Management
              Expanded(
                child: _buildActionCard(
                  'Manage',
                  Icons.manage_search,
                  Colors.blue,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VehicleManagementPage())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
