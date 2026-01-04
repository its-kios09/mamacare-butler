import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mamacare_flutter/main.dart';
import 'package:mamacare_flutter/services/storage_service.dart';
import 'package:mamacare_flutter/services/auth_service.dart';
import 'package:mamacare_flutter/services/emergency_service.dart';
import 'package:mamacare_flutter/screens/auth/phone_input_screen.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/app_drawer.dart';
import '../health_checkin/health_checkin_screen.dart';
import '../kick_counter/kick_counter_screen.dart';
import '../medication/medication_list_screen.dart';
import '../ultrasound/ultrasound_upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  // User data
  String _userName = '';
  int _currentWeek = 0;
  int _weeksRemaining = 0;
  int _daysRemaining = 0;
  double _progressPercentage = 0.0;
  String _trimester = '';
  DateTime? _dueDate;
  dynamic _profile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final userId = StorageService().getUserId();

      if (userId == null) {
        await _authService.logout();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
              (route) => false,
        );
        return;
      }

      final profile = await client.v1MaternalProfile.getProfile(userId);

      if (profile == null) {
        setState(() {
          _userName = 'User';
          _isLoading = false;
        });
        return;
      }

      // Calculate pregnancy metrics
      final now = DateTime.now();
      final dueDate = profile.expectedDueDate;
      final daysUntilDue = dueDate.difference(now).inDays;
      final weeksUntilDue = (daysUntilDue / 7).floor();
      final currentWeek = 40 - weeksUntilDue;
      final progressPercent = (currentWeek / 40) * 100;

      // Determine trimester
      String trimester;
      if (currentWeek <= 12) {
        trimester = 'First Trimester';
      } else if (currentWeek <= 26) {
        trimester = 'Second Trimester';
      } else {
        trimester = 'Third Trimester';
      }

      setState(() {
        _profile = profile;
        _userName = profile.fullName;
        _currentWeek = currentWeek > 0 ? currentWeek : 1;
        _weeksRemaining = weeksUntilDue > 0 ? weeksUntilDue : 0;
        _daysRemaining = daysUntilDue > 0 ? daysUntilDue : 0;
        _progressPercentage = progressPercent.clamp(0.0, 100.0);
        _trimester = trimester;
        _dueDate = dueDate;
        _isLoading = false;
      });
    } catch (e) {
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
  Future<void> _triggerEmergencySOS() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.sp),
            SizedBox(width: 12.w),
            const Text('Emergency SOS'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will send an emergency alert with:',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16.sp, color: Colors.red[700]),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text('Your name & phone number',
                            style: TextStyle(fontSize: 13.sp)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.pregnant_woman, size: 16.sp, color: Colors.red[700]),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text('Pregnancy week: $_currentWeek',
                            style: TextStyle(fontSize: 13.sp)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16.sp, color: Colors.red[700]),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text('Your current location',
                            style: TextStyle(fontSize: 13.sp)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16.sp, color: Colors.red[700]),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text('Current time',
                            style: TextStyle(fontSize: 13.sp)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[800], size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Only use in real emergencies!',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: Icon(Icons.send, size: 18.sp),
            label: Text('Send SOS', style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Trigger SOS
    try {
      HapticFeedback.heavyImpact(); // Vibrate

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.red, strokeWidth: 3),
                SizedBox(height: 16.h),
                Text('Sending Emergency SOS...',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      );

      // Get emergency service
      final emergencyService = EmergencyService();

      // Request permissions
      final hasPermissions = await emergencyService.requestPermissions();
      if (!hasPermissions) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text('Please grant SMS and location permissions'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      List<String> emergencyContacts = [];

      if (_profile?.emergencyPhone != null && _profile!.emergencyPhone.isNotEmpty) {
        emergencyContacts.add(_profile!.emergencyPhone);
      }

      print('Emergency contact phone: ${_profile?.emergencyPhone}');

      if (emergencyContacts.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text('Please add emergency contacts in your profile first'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Add Now',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to profile settings
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        );
        return;
      }

      // Send SOS
      final success = await emergencyService.sendEmergencySOS(
        emergencyContacts: emergencyContacts, // Now passing List<String>
        userName: _profile?.fullName ?? 'MamaCare User',
        pregnancyWeek: _currentWeek,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '✅ Emergency SOS sent to ${emergencyContacts.length} contact${emergencyContacts.length == 1 ? '' : 's'}!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text('Some SOS messages may not have been sent'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      print('❌ Error triggering SOS: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getBabyDevelopment() {
    final developments = {
      1: 'Conception has occurred! Your baby is just a tiny cluster of cells.',
      4: 'Your baby is the size of a poppy seed!',
      8: 'Baby\'s heart is beating and organs are forming.',
      12: 'Your baby can make a fist and has unique fingerprints!',
      16: 'Baby can hear sounds now! Talk to them.',
      20: 'Halfway there! Baby is very active.',
      24: 'Baby can hear your voice and recognize it! 👂',
      28: 'Baby\'s eyes can open and close.',
      32: 'Baby is practicing breathing movements.',
      36: 'Baby is getting ready for birth!',
      40: 'Your baby is ready to meet you! 👶',
    };

    int closestWeek = 1;
    for (var week in developments.keys) {
      if (_currentWeek >= week) {
        closestWeek = week;
      }
    }

    return developments[closestWeek] ?? 'Your baby is growing!';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: customAppBar(),
      drawer: AppDrawer(
        userName: _userName,
        currentWeek: _currentWeek,
      ),
      // Floating Action Button - Emergency SOS
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _triggerEmergencySOS,
        backgroundColor: Colors.red,
        icon: Icon(Icons.emergency, size: 24.sp, color: Colors.white),
        label: Text(
          'SOS',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                '${_getGreeting()}, $_userName! 👋',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 24.h),

              // Pregnancy Progress Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Pregnancy Journey',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      'Week $_currentWeek of 40',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: _progressPercentage / 100,
                        minHeight: 12.h,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📅 Due Date',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _dueDate != null
                                  ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                  : 'Not set',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '⏱️ Time Left',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '$_daysRemaining days',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '($_weeksRemaining weeks)',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      '🌸 $_trimester',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Quick Actions
              Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.h),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 1.3,
                children: [
                  _buildQuickActionCard(
                    icon: Icons.directions_walk,
                    label: 'Kick Counter',
                    subtitle: 'Track movements',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const KickCounterScreen()),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.medication,
                    label: 'Medications',
                    subtitle: 'Track adherence',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MedicationListScreen()),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.assignment,
                    label: 'Check-in',
                    subtitle: 'Weekly questions',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HealthCheckinScreen(
                            pregnancyWeek: _currentWeek,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.camera_alt,
                    label: 'Ultrasound',
                    subtitle: 'Scan & analyze',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UltrasoundUploadScreen()),
                      );
                    },
                  )
                ],
              ),

              SizedBox(height: 24.h),

              // Baby Development
              Text(
                '👶 This Week (Week $_currentWeek)',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.h),

              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.pink[200]!),
                ),
                child: Text(
                  _getBabyDevelopment(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 80.h), // Extra space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.sp,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}