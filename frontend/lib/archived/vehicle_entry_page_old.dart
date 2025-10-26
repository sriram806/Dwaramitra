import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/custom_toast.dart';
import 'package:frontend/features/vehicles/presentation/bloc/vehicle_log_cubit.dart';

class VehicleEntryPage extends StatefulWidget {
  const VehicleEntryPage({super.key});

  static MaterialPageRoute route() => MaterialPageRoute(
    builder: (context) => const VehicleEntryPage(),
  );

  @override
  State<VehicleEntryPage> createState() => _VehicleEntryPageState();
}

class _VehicleEntryPageState extends State<VehicleEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _purposeController = TextEditingController();
  
  String _selectedOwnerType = 'student';
  String _selectedVehicleType = 'car';
  String? _userShift;
  String? _userGate;
  String? _userName;

  final List<String> _ownerTypes = ['student', 'faculty', 'staff', 'visitor'];
  final List<String> _vehicleTypes = ['car', 'bike', 'bicycle', 'scooter', 'other'];
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  void _loadUserData() {
    // TODO: Get user data from auth cubit
    // For now, using placeholder data
    _userName = "Current User";
    _userShift = "Day Shift";
    _userGate = "GATE 1";
    _ownerNameController.text = _userName ?? "";
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _ownerNameController.dispose();
    _contactNumberController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<VehicleLogCubit>().logVehicleEntry(
        vehicleNumber: _vehicleNumberController.text.trim(),
        vehicleType: _selectedVehicleType,
        ownerName: _ownerNameController.text.trim(),
        ownerType: _selectedOwnerType,
        contactNumber: _contactNumberController.text.trim(),
        purpose: _purposeController.text.trim(),
        entryGate: _userGate ?? 'GATE 1',
        entryShift: _userShift ?? 'Day Shift',
        guardId: 'current_user_id', // You can get this from auth cubit
        guardName: 'Current User', // You can get this from auth cubit
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle Entry',
          style: AppTextStyles.headingSmall.copyWith(
            color: AppPallete.whiteColor,
          ),
        ),
        backgroundColor: AppPallete.gradient2,
        foregroundColor: AppPallete.whiteColor,
      ),
      body: BlocListener<VehicleLogCubit, VehicleLogState>(
        listener: (context, state) {
          if (state is VehicleLogEntrySuccess) {
            CustomToast.showSuccess(
              context: context,
              message: 'Vehicle entry logged successfully!',
            );
            Navigator.pop(context, state.logEntry);
          } else if (state is VehicleLogError) {
            CustomToast.showError(
              context: context,
              message: state.message,
            );
          }
        },
        child: BlocBuilder<VehicleLogCubit, VehicleLogState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Info Display
                      Card(
                        color: AppPallete.gradient2.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Entry Information',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Shift: ${_userShift ?? "Not Assigned"}'),
                                  ),
                                  Expanded(
                                    child: Text('Gate: ${_userGate ?? "Not Assigned"}'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Vehicle Number
                      TextFormField(
                        controller: _vehicleNumberController,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          prefixIcon: const Icon(Icons.directions_car),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vehicle number is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Vehicle Type
                      DropdownButtonFormField<String>(
                        value: _selectedVehicleType,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          prefixIcon: const Icon(Icons.directions_car),
                        ),
                        items: _vehicleTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleType = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Owner Name
                      TextFormField(
                        controller: _ownerNameController,
                        decoration: InputDecoration(
                          labelText: 'Owner Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Owner name is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Contact Number
                      TextFormField(
                        controller: _contactNumberController,
                        decoration: InputDecoration(
                          labelText: 'Contact Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Contact number is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Owner Type
                      DropdownButtonFormField<String>(
                        value: _selectedOwnerType,
                        decoration: InputDecoration(
                          labelText: 'Owner Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        items: _ownerTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedOwnerType = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Purpose (not required for faculty)
                      TextFormField(
                        controller: _purposeController,
                        decoration: InputDecoration(
                          labelText: _selectedOwnerType == 'faculty' 
                              ? 'Purpose (Optional)' 
                              : 'Purpose',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          // Purpose is not required for faculty
                          if (_selectedOwnerType != 'faculty' && 
                              (value == null || value.trim().isEmpty)) {
                            return 'Purpose is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                        ),
                        prefixIcon: const Icon(Icons.directions_car),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter vehicle number';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Owner Type
                    DropdownButtonFormField<String>(
                      value: _selectedOwnerType,
                      decoration: InputDecoration(
                        labelText: 'Owner Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: _ownerTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOwnerType = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Purpose
                    TextFormField(
                      controller: _purposeController,
                      decoration: InputDecoration(
                        labelText: 'Purpose of Visit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter purpose of visit';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Entry Gate
                    DropdownButtonFormField<String>(
                      value: _selectedGate,
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
                          child: Text(gate.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGate = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Shift
                    DropdownButtonFormField<String>(
                      value: _selectedShift,
                      decoration: InputDecoration(
                        labelText: 'Shift',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                      items: _shifts.map((shift) {
                        return DropdownMenuItem(
                          value: shift,
                          child: Text(shift.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedShift = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Submit Button
                    ElevatedButton(
                      onPressed: state is VehicleLogLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient2,
                        foregroundColor: AppPallete.whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                      ),
                      child: state is VehicleLogLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppPallete.whiteColor,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Log Entry',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppPallete.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}