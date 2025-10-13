import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/vehicles/cubit/vehicle_cubit.dart';
import 'package:frontend/models/vehicle_model.dart';

class EditVehiclePage extends StatefulWidget {
  final VehicleModel vehicle;

  const EditVehiclePage({super.key, required this.vehicle});

  @override
  State<EditVehiclePage> createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _parkingSlotController = TextEditingController();
  final _parkingFeeController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedVehicleType = 'car';
  final List<String> _vehicleTypes = ['car', 'bike', 'truck', 'bus', 'other'];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _vehicleNumberController.text = widget.vehicle.plateNumber;
    _selectedVehicleType = widget.vehicle.vehicleType;
    _ownerNameController.text = widget.vehicle.ownerName;
    _ownerPhoneController.text = widget.vehicle.ownerPhone;
    _parkingSlotController.text = widget.vehicle.parkingSlot ?? '';
    _parkingFeeController.text = widget.vehicle.parkingFee?.toString() ?? '0.0';
    _notesController.text = ''; // Notes not available in current model
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _parkingSlotController.dispose();
    _parkingFeeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Vehicle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4285F4),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocListener<VehicleCubit, VehicleState>(
        listener: (context, state) {
          if (state is VehicleOperationSuccess) {
            Navigator.of(context).pop();
          } else if (state is VehicleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vehicle Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4285F4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Vehicle Number
                        TextFormField(
                          controller: _vehicleNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Vehicle Number *',
                            prefixIcon: Icon(Icons.confirmation_number),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter vehicle number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Vehicle Type
                        DropdownButtonFormField<String>(
                          initialValue: _selectedVehicleType,
                          decoration: const InputDecoration(
                            labelText: 'Vehicle Type *',
                            prefixIcon: Icon(Icons.directions_car),
                            border: OutlineInputBorder(),
                          ),
                          items: _vehicleTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Text(_getVehicleTypeIcon(type)),
                                  const SizedBox(width: 8),
                                  Text(type.toUpperCase()),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicleType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Parking Slot
                        TextFormField(
                          controller: _parkingSlotController,
                          decoration: const InputDecoration(
                            labelText: 'Parking Slot *',
                            prefixIcon: Icon(Icons.local_parking),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter parking slot';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Owner Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4285F4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Owner Name
                        TextFormField(
                          controller: _ownerNameController,
                          decoration: const InputDecoration(
                            labelText: 'Owner Name *',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter owner name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Owner Phone
                        TextFormField(
                          controller: _ownerPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Owner Phone *',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter owner phone number';
                            }
                            if (value.trim().length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4285F4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Parking Fee
                        TextFormField(
                          controller: _parkingFeeController,
                          decoration: const InputDecoration(
                            labelText: 'Parking Fee (₹)',
                            prefixIcon: Icon(Icons.currency_rupee),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final fee = double.tryParse(value);
                              if (fee == null || fee < 0) {
                                return 'Please enter a valid fee amount';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Notes
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            prefixIcon: Icon(Icons.note),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                BlocBuilder<VehicleCubit, VehicleState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is VehicleUpdating ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4285F4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is VehicleUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Update Vehicle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final parkingFee = _parkingFeeController.text.isNotEmpty
          ? double.tryParse(_parkingFeeController.text) ?? 0.0
          : 0.0;

      context.read<VehicleCubit>().updateVehicle(
        id: widget.vehicle.id,
        vehicleNumber: _vehicleNumberController.text.trim(),
        vehicleType: _selectedVehicleType,
        ownerName: _ownerNameController.text.trim(),
        ownerPhone: _ownerPhoneController.text.trim(),
        parkingSlot: _parkingSlotController.text.trim(),
        parkingFee: parkingFee,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );
    }
  }
}