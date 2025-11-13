import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/custom_toast.dart';

class GuardCheckInOutPage extends StatefulWidget {
  const GuardCheckInOutPage({super.key});

  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const GuardCheckInOutPage(),
      );

  @override
  State<GuardCheckInOutPage> createState() => _GuardCheckInOutPageState();
}

class _GuardCheckInOutPageState extends State<GuardCheckInOutPage> {
  bool _isLoading = false;
  bool _isOnDuty = false;
  String? _userShift;
  String? _userGate;
  DateTime? _lastCheckInTime;
  int _vehiclesProcessed = 0;

  final List<String> _gates = ['GATE 1', 'GATE 2'];
  final List<String> _shifts = ['Day Shift', 'Night Shift'];

  @override
  void initState() {
    super.initState();
    _loadGuardStatus();
  }

  Future<void> _loadGuardStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Get actual user data from auth system
      // For now, using placeholder data
      _userShift = "Day Shift";
      _userGate = "GATE 1";
      
      // In a real implementation, you would fetch the current guard status from the API
      // final response = await ApiService.get('/users/profile');
      // final user = response['user'];
      // _isOnDuty = user['isOnDuty'] ?? false;
      // _lastCheckInTime = user['lastCheckIn'] != null 
      //     ? DateTime.parse(user['lastCheckIn']) 
      //     : null;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      CustomToast.showError(
        context: context,
        message: 'Error loading guard status: ${e.toString()}',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIn() async {
    if (_userGate == null) {
      CustomToast.showError(
        context: context,
        message: 'Please select a gate',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post(
        '/user/guard/check-in',
        data: {
          'gate': _userGate,
        },
      );

      if (response['success'] == true) {
        CustomToast.showSuccess(
          context: context,
          message: response['message'] ?? 'Checked in successfully!',
        );
        
        setState(() {
          _isOnDuty = true;
          _lastCheckInTime = DateTime.now();
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to check in');
      }
    } catch (e) {
      CustomToast.showError(
        context: context,
        message: 'Error checking in: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post(
        '/user/guard/check-out',
        data: {},
      );

      if (response['success'] == true) {
        CustomToast.showSuccess(
          context: context,
          message: response['message'] ?? 'Checked out successfully!',
        );
        
        setState(() {
          _isOnDuty = false;
          _lastCheckInTime = null;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to check out');
      }
    } catch (e) {
      CustomToast.showError(
        context: context,
        message: 'Error checking out: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Guard Check In/Out',
          style: AppTextStyles.headingSmall.copyWith(
            color: AppPallete.whiteColor,
          ),
        ),
        backgroundColor: AppPallete.gradient2,
        foregroundColor: AppPallete.whiteColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    color: _isOnDuty
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: _isOnDuty ? Colors.green : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _isOnDuty ? 'ON DUTY' : 'OFF DUTY',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (_isOnDuty && _lastCheckInTime != null)
                            Text(
                              'Checked in at: ${_lastCheckInTime!.toLocal().toString().split('.').first}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          if (!_isOnDuty)
                            const Text(
                              'You are currently off duty',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Shift and Gate Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assignment Information',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              const Icon(Icons.access_time),
                              const SizedBox(width: AppSpacing.sm),
                              Text(_userShift ?? 'Not Assigned'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(width: AppSpacing.sm),
                              Text(_userGate ?? 'Not Assigned'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Gate Selection (only when not on duty)
                  if (!_isOnDuty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Gate',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            DropdownButtonFormField<String>(
                              value: _userGate,
                              decoration: InputDecoration(
                                labelText: 'Entry Gate',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                                ),
                                prefixIcon: const Icon(Icons.location_on),
                              ),
                              items: _gates.map((gate) {
                                return DropdownMenuItem(
                                  value: gate,
                                  child: Text(gate),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _userGate = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Action Buttons
                  if (_isOnDuty)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _checkOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'CHECK OUT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _isLoading ? null : _checkIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient2,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'CHECK IN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Stats
                  if (_isOnDuty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Activity',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Vehicles Processed'),
                                Text(
                                  '$_vehiclesProcessed',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}