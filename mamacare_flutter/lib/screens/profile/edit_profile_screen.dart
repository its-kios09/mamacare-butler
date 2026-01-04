import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/storage_service.dart';
import '../../constants/constant.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentProfile;

  const EditProfileScreen({
    super.key,
    required this.currentProfile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _allergiesController;
  late TextEditingController _medicalHistoryController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current values
    _nameController = TextEditingController(text: widget.currentProfile['name'] ?? '');
    _emergencyContactController = TextEditingController(text: widget.currentProfile['emergencyContact'] ?? '');
    _emergencyPhoneController = TextEditingController(text: widget.currentProfile['emergencyPhone'] ?? '');
    _bloodTypeController = TextEditingController(text: widget.currentProfile['bloodType'] ?? '');
    _allergiesController = TextEditingController(text: widget.currentProfile['allergies'] ?? '');
    _medicalHistoryController = TextEditingController(text: widget.currentProfile['medicalHistory'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      print('💾 Updating profile for user $userId');

      // Get current profile
      final currentProfile = await client.v1MaternalProfile.getProfile(userId);
      if (currentProfile == null) throw Exception('Profile not found');

      // Update profile with new values
      final updated = currentProfile.copyWith(
        fullName: _nameController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        bloodType: _bloodTypeController.text.trim().isEmpty
            ? null
            : _bloodTypeController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        medicalHistory: _medicalHistoryController.text.trim().isEmpty
            ? null
            : _medicalHistoryController.text.trim(),
      );

      final result = await client.v1MaternalProfile.updateProfile(updated);

      if (result == null) {
        throw Exception('Failed to update profile');
      }

      print('✅ Profile updated successfully');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return true to trigger refresh

    } catch (e) {
      print('❌ Error updating profile: $e');
      setState(() => _isSaving = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSectionHeader('Personal Information', Icons.person),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              _buildTextField(
                controller: _bloodTypeController,
                label: 'Blood Type (Optional)',
                icon: Icons.bloodtype,
                hint: 'e.g., A+, B-, O+',
              ),

              SizedBox(height: 24.h),

              // Emergency Contact Section
              _buildSectionHeader('Emergency Contact', Icons.emergency),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _emergencyContactController,
                label: 'Emergency Contact Name',
                icon: Icons.person_outline,
                hint: 'e.g., John Doe',
              ),

              SizedBox(height: 16.h),

              _buildTextField(
                controller: _emergencyPhoneController,
                label: 'Emergency Contact Phone',
                icon: Icons.phone,
                hint: '+254...',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.startsWith('+')) {
                      return 'Phone must start with country code (e.g., +254)';
                    }
                  }
                  return null;
                },
              ),

              SizedBox(height: 24.h),

              // Medical Information Section
              _buildSectionHeader('Medical Information', Icons.medical_information),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _allergiesController,
                label: 'Allergies (Optional)',
                icon: Icons.warning_amber,
                hint: 'e.g., Penicillin, Peanuts',
                maxLines: 2,
              ),

              SizedBox(height: 16.h),

              _buildTextField(
                controller: _medicalHistoryController,
                label: 'Medical History (Optional)',
                icon: Icons.history,
                hint: 'Previous conditions, surgeries, etc.',
                maxLines: 3,
              ),

              SizedBox(height: 32.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    side: BorderSide(color: kPrimaryColor),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: kPrimaryColor, size: 24.sp),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: kPrimaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: kPrimaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }
}