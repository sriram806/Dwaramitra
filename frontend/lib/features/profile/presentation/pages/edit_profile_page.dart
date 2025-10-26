import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../bloc/profile_cubit.dart';
import '../widgets/profile_page_scaffold.dart';
import '../widgets/profile_form_field.dart';
import 'package:frontend/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/widgets/custom_toast.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  static MaterialPageRoute route(UserModel user) => MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user),
      );

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController universityIdController;
  late TextEditingController departmentController;
  bool isLoading = false;
  bool isImageUploading = false;
  String? currentImageUrl;
  String? selectedGender;
  String? selectedDesignation;
  String? selectedShift;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone ?? '');
    universityIdController = TextEditingController(text: widget.user.universityId ?? '');
    departmentController = TextEditingController(text: widget.user.department ?? '');
    currentImageUrl = widget.user.avatar?.url;
    selectedGender = widget.user.gender;
    selectedDesignation = widget.user.designation;
    selectedShift = widget.user.shift;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    universityIdController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: 'Edit Profile',
      actions: [
        TextButton(
          onPressed: isLoading ? null : _saveProfile,
          child: Text(
            'Save',
            style: AppTextStyles.button.copyWith(
              color: AppPallete.primaryColor,
            ),
          ),
        ),
      ],
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            setState(() => isLoading = false);
            Navigator.pop(context);
            CustomToast.showSuccess(
              context: context,
              message: 'Profile updated successfully',
            );
          } else if (state is ProfileError) {
            setState(() => isLoading = false);
            CustomToast.showError(
              context: context,
              message: state.message,
            );
          }
        },
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                
                // Profile Avatar Section
                _buildProfileAvatarSection(),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Personal Information Section
                _buildSectionHeader('Personal Information', Icons.person),
                const SizedBox(height: AppSpacing.md),
                _buildPersonalInfoFields(),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Contact Information Section
                _buildSectionHeader('Contact Information', Icons.contact_phone),
                const SizedBox(height: AppSpacing.md),
                _buildContactInfoFields(),
                
                const SizedBox(height: AppSpacing.xl),
                
                // University Information Section
                _buildSectionHeader('University Information', Icons.school),
                const SizedBox(height: AppSpacing.md),
                _buildUniversityInfoFields(),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Save Button
                _buildSaveButton(),
                
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    final name = nameController.text.isNotEmpty ? nameController.text : widget.user.name;
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() => isImageUploading = true);
        
        // TODO: Implement image upload to server
        // For now, just show that the image was selected
        setState(() {
          isImageUploading = false;
          // currentImageUrl = image.path; // This would be the uploaded URL
        });

        CustomToast.showInfo(
          context: context,
          message: 'Image upload feature coming soon!',
        );
      }
    } catch (e) {
      setState(() => isImageUploading = false);
      CustomToast.showError(
        context: context,
        message: 'Failed to pick image: $e',
      );
    }
  }

  // Helper methods for role-based access control
  bool _isGuard() {
    return widget.user.role == 'guard';
  }

  bool _canEditShifts() {
    // Only security officers can edit shifts
    return widget.user.role == 'security officer';
  }

  bool _shouldShowShiftField() {
    // Show shift field if user is a guard or if current user can edit shifts
    return _isGuard() || _canEditShifts();
  }

  Future<void> _saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      await context.read<ProfileCubit>().updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        gender: selectedGender,
        universityId: universityIdController.text.trim().isEmpty ? null : universityIdController.text.trim(),
        department: departmentController.text.trim().isEmpty ? null : departmentController.text.trim(),
        designation: selectedDesignation,
        shift: selectedShift,
        avatar: currentImageUrl != null ? {'url': currentImageUrl} : null,
      );
    } catch (e) {
      setState(() => isLoading = false);
      CustomToast.showError(
        context: context,
        message: 'Failed to update profile: $e',
      );
    }
  }

  // New UI Helper Methods
  Widget _buildProfileAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: currentImageUrl != null && currentImageUrl!.isNotEmpty
                  ? Image.network(
                      currentImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackAvatar();
                      },
                    )
                  : _buildFallbackAvatar(),
            ),
          ),
          if (isImageUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoFields() {
    return Column(
      children: [
        ProfileFormField(
          label: 'Full Name',
          controller: nameController,
          prefixIcon: const Icon(Icons.person_outline),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _buildGenderDropdown(),
        const SizedBox(height: AppSpacing.md),
        _buildDesignationDropdown(),
        // Show shift field for guards or if user can edit shifts
        if (_shouldShowShiftField()) ...[
          const SizedBox(height: AppSpacing.md),
          _buildShiftDropdown(),
        ],
      ],
    );
  }

  Widget _buildContactInfoFields() {
    return Column(
      children: [
        ProfileFormField(
          label: 'Email Address',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        ProfileFormField(
          label: 'Phone Number',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUniversityInfoFields() {
    return Column(
      children: [
        ProfileFormField(
          label: 'University ID',
          controller: universityIdController,
          prefixIcon: const Icon(Icons.badge_outlined),
        ),
        const SizedBox(height: AppSpacing.md),
        ProfileFormField(
          label: 'Department',
          controller: departmentController,
          prefixIcon: const Icon(Icons.business_outlined),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return ProfileDropdownField<String>(
      label: 'Gender',
      value: selectedGender,
      items: ['Male', 'Female'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedGender = newValue;
        });
      },
    );
  }

  Widget _buildDesignationDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDesignation,
      decoration: InputDecoration(
        labelText: 'Designation',
        prefixIcon: Icon(Icons.work_outline, color: Theme.of(context).primaryColor.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: TextStyle(color: Colors.grey.shade700),
      ),
      items: ['Student', 'Staff', 'Faculty', 'Admin Staff', 'Visitor'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedDesignation = newValue;
        });
      },
    );
  }

  Widget _buildShiftDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedShift,
      decoration: InputDecoration(
        labelText: 'Shift Assignment',
        prefixIcon: Icon(Icons.schedule_outlined, color: Theme.of(context).primaryColor.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: _canEditShifts() ? Colors.grey.shade50 : Colors.grey.shade100,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        helperText: _canEditShifts() ? 'Only security officers can modify shifts' : 'Contact security officer to change shift',
        helperStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      items: ['Day Shift', 'Night Shift'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: [
              Icon(
                value == 'Day Shift' ? Icons.wb_sunny : Icons.nightlight_round,
                size: 20,
                color: value == 'Day Shift' ? Colors.orange : Colors.indigo,
              ),
              const SizedBox(width: 8),
              Text(value),
            ],
          ),
        );
      }).toList(),
      onChanged: _canEditShifts() ? (String? newValue) {
        setState(() {
          selectedShift = newValue;
        });
      } : null, // Disable dropdown if user cannot edit shifts
      validator: _isGuard() ? (value) {
        if (value == null || value.isEmpty) {
          return 'Shift assignment is required for guards';
        }
        return null;
      } : null,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
