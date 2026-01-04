import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/storage_service.dart';
import '../../constants/constant.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      final profile = await client.v1MaternalProfile.getProfile(userId);

      if (profile == null) throw Exception('Profile not found');

      setState(() {
        _profile = {
          'name': profile.fullName,
          'pregnancyWeek': profile.currentWeek,
          'dueDate': profile.expectedDueDate,
          'emergencyContact': profile.emergencyContact,
          'emergencyPhone': profile.emergencyPhone,
          'bloodType': profile.bloodType,
          'allergies': profile.allergies,
          'medicalHistory': profile.medicalHistory,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading profile: $e');
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _calculateWeeksPregnant() {
    if (_profile == null || _profile!['dueDate'] == null) return 0;

    final dueDate = _profile!['dueDate'] as DateTime;
    final today = DateTime.now();
    final weeksUntilDue = dueDate.difference(today).inDays ~/ 7;

    return 40 - weeksUntilDue;
  }

  int _getDaysUntilDue() {
    if (_profile == null || _profile!['dueDate'] == null) return 0;

    final dueDate = _profile!['dueDate'] as DateTime;
    final today = DateTime.now();

    return dueDate.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, size: 24.sp),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(currentProfile: _profile!),
                ),
              );

              // Reload profile if updated
              if (result == true) {
                _loadProfile();
              }
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 3),
      )
          : RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(),

              SizedBox(height: 24.h),

              // Pregnancy Progress
              _buildPregnancyProgress(),

              SizedBox(height: 24.h),

              // Personal Information
              _buildSection(
                title: 'Personal Information',
                icon: Icons.person,
                children: [
                  _buildInfoRow('Full Name', _profile!['name'] ?? 'N/A'),
                  _buildInfoRow('Phone Number', _profile!['phoneNumber'] ?? 'N/A'),
                  if (_profile!['bloodType'] != null && _profile!['bloodType'].toString().isNotEmpty)
                    _buildInfoRow('Blood Type', _profile!['bloodType']),
                ],
              ),

              SizedBox(height: 16.h),

              // Emergency Contact
              _buildSection(
                title: 'Emergency Contact',
                icon: Icons.emergency,
                children: [
                  _buildInfoRow('Contact Name', _profile!['emergencyContact'] ?? 'Not set'),
                  _buildInfoRow('Contact Phone', _profile!['emergencyPhone'] ?? 'Not set'),
                ],
              ),

              SizedBox(height: 16.h),

              // Medical Information
              if (_profile!['allergies'] != null || _profile!['medicalHistory'] != null)
                _buildSection(
                  title: 'Medical Information',
                  icon: Icons.medical_information,
                  children: [
                    if (_profile!['allergies'] != null && _profile!['allergies'].toString().isNotEmpty)
                      _buildInfoRow('Allergies', _profile!['allergies']),
                    if (_profile!['medicalHistory'] != null && _profile!['medicalHistory'].toString().isNotEmpty)
                      _buildInfoRow('Medical History', _profile!['medicalHistory']),
                  ],
                ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 60.sp,
              color: kPrimaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            _profile!['name'] ?? 'User',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Week ${_calculateWeeksPregnant()} of 40',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyProgress() {
    final weeksPregnant = _calculateWeeksPregnant();
    final daysUntilDue = _getDaysUntilDue();
    final progress = (weeksPregnant / 40).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregnancy Progress',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: kPrimaryColor,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat('Weeks', '$weeksPregnant / 40', Icons.calendar_today),
              _buildProgressStat('Days to Go', '$daysUntilDue', Icons.event),
              _buildProgressStat(
                'Due Date',
                _profile!['dueDate'] != null
                    ? DateFormat('MMM dd').format(_profile!['dueDate'])
                    : 'N/A',
                Icons.child_care,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryColor, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}