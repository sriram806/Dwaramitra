import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend/features/vehicles/presentation/pages/vehicle_management_page.dart';
import 'package:frontend/features/vehicles/presentation/pages/vehicle_entry_page.dart';
import 'package:frontend/features/guards/presentation/pages/guard_management_page.dart';
import 'package:frontend/features/guards/presentation/pages/guard_check_in_out_page.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/features/vehicles/data/models/vehicle_log_model.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/announcements/presentation/cubit/announcement_cubit.dart';
import 'package:frontend/features/announcements/data/repositories/announcement_repository.dart';
import 'package:frontend/features/announcements/presentation/pages/announcements_page.dart';
import 'package:frontend/features/vehicles/presentation/bloc/vehicle_log_cubit.dart';

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
  List<VehicleLogModel> vehicleLogs = [];
  List<VehicleLogModel> filteredLogs = [];
  String selectedFilter = 'all'; // 'all', 'parked', 'exited'
  bool isLoadingData = true;
  Map<String, dynamic>? dashboardStats;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Show the page immediately, then load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicleLogs();
    });
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

  void _loadVehicleLogs() async {
    if (mounted) {
      // Load dashboard stats
      context.read<VehicleLogCubit>().getDashboardStats();
      
      // Load vehicle logs
      context.read<VehicleLogCubit>().getVehicleLogs();
    }
  }

  void _applyFilter() {
    setState(() {
      List<VehicleLogModel> userFilteredLogs;
      
      if (currentUser?.role == 'admin') {
        userFilteredLogs = List.from(vehicleLogs);
      } else {
        userFilteredLogs = vehicleLogs.where((v) => 
          v.ownerName == currentUser?.name || 
          v.universityId == currentUser?.universityId
        ).toList();
      }
      
      switch (selectedFilter) {
        case 'parked':
          filteredLogs = userFilteredLogs.where((v) => v.isParked).toList();
          break;
        case 'exited':
          filteredLogs = userFilteredLogs.where((v) => v.hasExited).toList();
          break;
        default:
          filteredLogs = userFilteredLogs;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<VehicleLogCubit, VehicleLogState>(
          listener: (context, state) {
            if (state is VehicleLogLoaded) {
              setState(() {
                vehicleLogs = state.logs;
                isLoadingData = false;
              });
              _applyFilter();
            } else if (state is DashboardStatsLoaded) {
              setState(() {
                dashboardStats = state.stats;
              });
            } else if (state is VehicleLogError) {
              setState(() {
                isLoadingData = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
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
                              _buildStatCard(
                                'Total', 
                                '${dashboardStats?['total'] ?? vehicleLogs.length}', 
                                Icons.directions_car
                              ),
                              _buildStatCard(
                                'Parked', 
                                '${dashboardStats?['parked'] ?? vehicleLogs.where((v) => v.isParked).length}', 
                                Icons.local_parking
                              ),
                              _buildStatCard(
                                'Exited', 
                                '${dashboardStats?['exited'] ?? vehicleLogs.where((v) => v.hasExited).length}', 
                                Icons.exit_to_app
                              ),
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
                      child: filteredLogs.isEmpty
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
                              itemCount: filteredLogs.length,
                              itemBuilder: (context, index) {
                                final log = filteredLogs[index];
                                return _buildVehicleLogCard(log);
                              },
                            ),
                    ),
                  ],
                ),
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

  Widget _buildVehicleLogCard(VehicleLogModel log) {
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
                    color: log.isParked ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    log.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  log.vehicleNumber,
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
                Text(log.ownerName, style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Icon(
                  log.vehicleType.toLowerCase().contains('bike') ? Icons.motorcycle : Icons.directions_car,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(log.vehicleType),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Entry: ${DateFormat('MMM dd, HH:mm').format(log.entryTime)}',
                ),
              ],
            ),
            if (log.exitTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.exit_to_app, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Exit: ${DateFormat('MMM dd, HH:mm').format(log.exitTime!)}',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text('Duration: ${log.formattedDuration}'),
                const Spacer(),
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(log.entryGate),
              ],
            ),
            if (log.isParked) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showExitVehicleDialog(log),
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

  void _showExitVehicleDialog(VehicleLogModel log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Vehicle Exit'),
        content: Text('Mark ${log.vehicleNumber} as exited?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markVehicleExit(log);
            },
            child: const Text('Mark Exit'),
          ),
        ],
      ),
    );
  }

  void _markVehicleExit(VehicleLogModel log) {
    context.read<VehicleLogCubit>().logVehicleExit(logId: log.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${log.vehicleNumber} marked as exited'),
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
              
              // Guard Check In/Out for guards
              if (currentUser?.role == 'guard') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    'Check In/Out',
                    Icons.login_outlined,
                    Colors.purple,
                    () => Navigator.push(context, GuardCheckInOutPage.route()),
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
    final parkedLogs = filteredLogs.where((v) => v.isParked).toList();
    
    if (parkedLogs.isEmpty) {
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
            itemCount: parkedLogs.length,
            itemBuilder: (context, index) {
              final log = parkedLogs[index];
              return ListTile(
                leading: Icon(
                  log.vehicleType.toLowerCase().contains('bike') ? Icons.motorcycle :
                  log.vehicleType.toLowerCase().contains('car') ? Icons.directions_car :
                  Icons.local_shipping,
                  color: Colors.blue,
                ),
                title: Text(log.vehicleNumber),
                subtitle: Text('${log.ownerName} - ${log.vehicleType}'),
                onTap: () {
                  Navigator.pop(context);
                  _showExitVehicleDialog(log);
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