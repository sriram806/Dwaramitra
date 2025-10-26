import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend/features/vehicles/presentation/pages/vehicle_management_page.dart';
import 'package:frontend/features/vehicles/presentation/pages/vehicle_entry_page.dart';
import 'package:frontend/features/guards/presentation/pages/guard_management_page.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/features/vehicles/data/models/vehicle_model.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/announcements/presentation/cubit/announcement_cubit.dart';
import 'package:frontend/features/announcements/data/repositories/announcement_repository.dart';
import 'package:frontend/features/announcements/presentation/pages/announcements_page.dart';

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
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (mounted) {
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
    // Sample vehicle data for demonstration - assign different owners for testing
    vehicles = [
      VehicleModel(
        id: '1',
        vehicleNumber: 'ABC-123',
        vehicleType: 'four-wheeler',
        ownerName: currentUser?.name ?? 'John Doe',
        ownerRole: currentUser?.role ?? 'student',
        universityId: currentUser?.universityId ?? 'STU001',
        department: currentUser?.department ?? 'Computer Science',
        contactNumber: '+1234567890',
        entryTime: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'inside',
        gateName: 'GATE 1',
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
        gateName: 'GATE 2',
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
        gateName: 'GATE 1',
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
      List<VehicleModel> userFilteredVehicles;
      
      if (currentUser?.role == 'admin') {
        userFilteredVehicles = List.from(vehicles);
      } else {
        userFilteredVehicles = vehicles.where((v) => 
          v.ownerName == currentUser?.name || 
          v.universityId == currentUser?.universityId
        ).toList();
      }
      
      switch (selectedFilter) {
        case 'parked':
          filteredVehicles = userFilteredVehicles.where((v) => v.isParked).toList();
          break;
        case 'exited':
          filteredVehicles = userFilteredVehicles.where((v) => v.hasExited).toList();
          break;
        default:
          filteredVehicles = userFilteredVehicles;
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

                  // Announcements (small preview)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: BlocProvider(
                      create: (_) => AnnouncementCubit(AnnouncementRepository())..getActiveAnnouncements(),
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text('Announcements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.push(context, AnnouncementsPage.route()),
                                      child: const Text('View all'),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                BlocBuilder<AnnouncementCubit, AnnouncementState>(
                                  builder: (context, state) {
                                    if (state is AnnouncementLoading) {
                                      return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                                    }

                                    if (state is AnnouncementLoaded && state.announcements.isNotEmpty) {
                                      final items = state.announcements.take(3).toList();
                                      return Column(
                                        children: items.map((a) => ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                          subtitle: Text(a.message, maxLines: 1, overflow: TextOverflow.ellipsis),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.open_in_new),
                                            onPressed: () => Navigator.push(context, AnnouncementsPage.route()),
                                          ),
                                        )).toList(),
                                      );
                                    }

                                    return const Text('No announcements');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
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
              // Vehicle Entry
              Expanded(
                child: _buildActionCard(
                  'Log Entry',
                  Icons.login,
                  Colors.green,
                  () => Navigator.push(context, VehicleEntryPage.route()),
                ),
              ),
              const SizedBox(width: 12),
              
              // Vehicle Exit
              Expanded(
                child: _buildActionCard(
                  'Log Exit',
                  Icons.logout,
                  Colors.orange,
                  () => _showVehicleExitDialog(),
                ),
              ),
              
              // Show Management for admin and security officer
              if (currentUser?.role == 'admin' || currentUser?.role == 'security officer') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    currentUser?.role == 'admin' ? 'Manage' : 'Manage Guards',
                    currentUser?.role == 'admin' ? Icons.manage_search : Icons.security,
                    Colors.blue,
                    () {
                      if (currentUser?.role == 'admin') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const VehicleManagementPage()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const GuardManagementPage()));
                      }
                    },
                  ),
                ),
              ],
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

  void _showVehicleExitDialog() {
    // Filter vehicles that are currently parked (inside)
    final parkedVehicles = filteredVehicles.where((v) => v.status == 'inside').toList();
    
    if (parkedVehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No vehicles currently parked')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Vehicle to Exit'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: parkedVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = parkedVehicles[index];
              return ListTile(
                leading: Icon(
                  vehicle.vehicleType == 'car' ? Icons.directions_car :
                  vehicle.vehicleType == 'bike' ? Icons.motorcycle :
                  Icons.local_shipping,
                  color: Colors.blue,
                ),
                title: Text(vehicle.plateNumber),
                subtitle: Text('${vehicle.ownerName} - ${vehicle.vehicleType}'),
                onTap: () {
                  Navigator.pop(context);
                  _showExitVehicleDialog(vehicle);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

}
