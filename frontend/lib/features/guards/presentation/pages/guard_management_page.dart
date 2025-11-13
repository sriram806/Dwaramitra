import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/custom_toast.dart';
import 'package:frontend/models/user_model.dart';

class GuardManagementPage extends StatefulWidget {
  const GuardManagementPage({super.key});

  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const GuardManagementPage(),
      );

  @override
  State<GuardManagementPage> createState() => _GuardManagementPageState();
}

class _GuardManagementPageState extends State<GuardManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> guards = [];
  bool isLoading = true;
  String selectedShift = 'all';
  String selectedGate = 'all';
  String selectedStatus = 'all';
  int currentPage = 1;
  int totalPages = 1;
  bool hasNextPage = false;
  bool hasPrevPage = false;

  final List<String> shifts = ['all', 'Day Shift', 'Night Shift'];
  final List<String> gates = ['all', 'GATE 1', 'GATE 2'];
  final List<String> statuses = ['all', 'on-duty', 'off-duty'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGuards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGuards() async {
    setState(() {
      isLoading = true;
    });

    try {
      final queryParameters = {
        'page': currentPage.toString(),
        'limit': '10',
        if (selectedShift != 'all') 'shift': selectedShift,
        if (selectedGate != 'all') 'gate': selectedGate,
        if (selectedStatus != 'all') 'status': selectedStatus,
      };

      final response = await ApiService.get(
        '/user/guards/all',
        queryParameters: queryParameters,
      );

      if (response['success'] == true) {
        final List<dynamic> guardsData = response['guards'];
        final pagination = response['pagination'];

        setState(() {
          guards = guardsData.map((guard) => UserModel.fromMap(guard)).toList();
          if (pagination != null) {
            totalPages = pagination['totalPages'] ?? 1;
            hasNextPage = pagination['hasNext'] ?? false;
            hasPrevPage = pagination['hasPrev'] ?? false;
          }
          isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load guards');
      }
    } catch (e) {
      CustomToast.showError(
        context: context,
        message: 'Error loading guards: ${e.toString()}',
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditGuardDialog(UserModel guard) {
    final shiftController = TextEditingController(text: guard.shift);
    List<String> selectedGates = List.from(guard.assignedGates ?? []);
    bool isOnDuty = guard.isOnDuty ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Guard: ${guard.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shift Dropdown
                DropdownButtonFormField<String>(
                  value: shiftController.text.isNotEmpty ? shiftController.text : null,
                  decoration: const InputDecoration(
                    labelText: 'Shift',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Day Shift', 'Night Shift']
                      .map((shift) => DropdownMenuItem(
                            value: shift,
                            child: Text(shift),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      shiftController.text = value;
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Gates Selection
                const Text('Assigned Gates:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  children: ['GATE 1', 'GATE 2'].map((gate) {
                    return CheckboxListTile(
                      title: Text(gate),
                      value: selectedGates.contains(gate),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedGates.add(gate);
                          } else {
                            selectedGates.remove(gate);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // On Duty Status
                CheckboxListTile(
                  title: const Text('On Duty'),
                  value: isOnDuty,
                  onChanged: (checked) {
                    setDialogState(() {
                      isOnDuty = checked ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateGuard(guard.id, shiftController.text, selectedGates, isOnDuty);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateGuard(String guardId, String shift, List<String> gates, bool isOnDuty) async {
    try {
      final response = await ApiService.put(
        '/user/guards/update/$guardId',
        data: {
          'shift': shift,
          'assignedGates': gates,
          'isOnDuty': isOnDuty,
        },
      );

      if (response['success'] == true) {
        CustomToast.showSuccess(
          context: context,
          message: 'Guard updated successfully!',
        );
        _loadGuards(); // Refresh the list
      } else {
        throw Exception(response['message'] ?? 'Failed to update guard');
      }
    } catch (e) {
      CustomToast.showError(
        context: context,
        message: 'Error updating guard: ${e.toString()}',
      );
    }
  }

  void _showActivityReport(UserModel guard) {
    // TODO: Implement actual activity report fetching
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Activity Report: ${guard.name}'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Activity report functionality will be implemented here.'),
              SizedBox(height: 16),
              Text('This will show:'),
              Text('- Check-in/out times'),
              Text('- Total hours worked'),
              Text('- Vehicle entries processed'),
              Text('- Gate assignments history'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (guards.isEmpty) {
      return const Center(
        child: Text(
          'No guards found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: guards.length,
            itemBuilder: (context, index) {
              final guard = guards[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: guard.isOnDuty == true ? Colors.green : Colors.grey,
                    child: Icon(
                      Icons.security,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    guard.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shift: ${guard.shift ?? "Not Assigned"}'),
                      Text('Gates: ${guard.assignedGates?.join(", ") ?? "None"}'),
                      Text(
                        'Status: ${guard.isOnDuty == true ? "On Duty" : "Off Duty"}',
                        style: TextStyle(
                          color: guard.isOnDuty == true ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'activity',
                        child: Row(
                          children: [
                            Icon(Icons.history),
                            SizedBox(width: 8),
                            Text('View Activity'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditGuardDialog(guard);
                          break;
                        case 'activity':
                          _showActivityReport(guard);
                          break;
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
        // Pagination controls
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: hasPrevPage
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                          _loadGuards();
                        }
                      : null,
                  child: const Text('Previous'),
                ),
                Text('Page $currentPage of $totalPages'),
                ElevatedButton(
                  onPressed: hasNextPage
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                          _loadGuards();
                        }
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: selectedShift,
              isExpanded: true,
              hint: const Text('Filter by Shift'),
              items: shifts.map((shift) => DropdownMenuItem(
                value: shift,
                child: Text(shift == 'all' ? 'All Shifts' : shift),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedShift = value ?? 'all';
                  currentPage = 1; // Reset to first page when filter changes
                });
                _loadGuards();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: selectedGate,
              isExpanded: true,
              hint: const Text('Filter by Gate'),
              items: gates.map((gate) => DropdownMenuItem(
                value: gate,
                child: Text(gate == 'all' ? 'All Gates' : gate),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGate = value ?? 'all';
                  currentPage = 1; // Reset to first page when filter changes
                });
                _loadGuards();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: selectedStatus,
              isExpanded: true,
              hint: const Text('Filter by Status'),
              items: statuses.map((status) => DropdownMenuItem(
                value: status,
                child: Text(status == 'all' ? 'All Status' : status.replaceAll('-', ' ')),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value ?? 'all';
                  currentPage = 1; // Reset to first page when filter changes
                });
                _loadGuards();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Guard Management',
          style: AppTextStyles.headingSmall.copyWith(
            color: AppPallete.whiteColor,
          ),
        ),
        backgroundColor: AppPallete.gradient2,
        foregroundColor: AppPallete.whiteColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppPallete.whiteColor,
          unselectedLabelColor: AppPallete.whiteColor.withOpacity(0.7),
          indicatorColor: AppPallete.whiteColor,
          tabs: const [
            Tab(text: 'All Guards'),
            Tab(text: 'On Duty'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGuardsList(),
                _buildGuardsList(), // TODO: Filter for on-duty guards
                const Center(
                  child: Text(
                    'Activity Reports\n\nThis will show:\n- Daily guard activities\n- Vehicle processing stats\n- Gate coverage reports\n- Performance metrics',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}