  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:mamacare_flutter/main.dart';
  import 'package:mamacare_flutter/services/storage_service.dart';
  import 'package:mamacare_flutter/services/auth_service.dart';
  import 'package:mamacare_flutter/screens/auth/phone_input_screen.dart';
  import '../../widgets/app_bar.dart';
  import '../../widgets/app_drawer.dart';
import '../kick_counter/kick_counter_screen.dart';

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
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                          MaterialPageRoute(builder: (_) => const KickCounterScreen()),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.medication,
                      label: 'Medications',
                      subtitle: 'Track meds',
                      color: Colors.green,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Medications - Coming soon!')),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.assignment,
                      label: 'Check-in',
                      subtitle: 'Weekly questions',
                      color: Colors.orange,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Check-in - Coming soon!')),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.camera_alt,
                      label: 'Ultrasound',
                      subtitle: 'Scan & analyze',
                      color: Colors.purple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ultrasound - Coming soon!')),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.analytics,
                      label: 'Charts',
                      subtitle: 'View insights',
                      color: Colors.teal,
                      onTap: () {
                        Navigator.pushNamed(context, '/health-trends');
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.emergency,
                      label: 'Emergency',
                      subtitle: 'SOS',
                      color: Colors.red,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Emergency SOS - Coming soon!')),
                        );
                      },
                    ),
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

                SizedBox(height: 24.h),
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