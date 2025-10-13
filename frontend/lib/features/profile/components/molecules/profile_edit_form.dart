import 'package:flutter/material.dart';
import '../atoms/profile_form_field.dart';

class ProfileEditForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController roleController;

  const ProfileEditForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.roleController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          ProfileFormField(
            controller: nameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: Icons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          
          ProfileFormField(
            controller: phoneController,
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
              }
              return null;
            },
          ),
          
          ProfileFormField(
            controller: roleController,
            labelText: 'Role/Position',
            hintText: 'Enter your role or position',
            prefixIcon: Icons.work,
            validator: (value) {
              // Role is optional, no validation needed
              return null;
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}