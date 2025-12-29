import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mamacare_flutter/screens/auth/phone_input_screen.dart';
import 'package:mamacare_flutter/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final int currentWeek;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.currentWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header - Made smaller
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
            accountName: Text(
              userName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              'Week $currentWeek',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ),

          // Health Trends
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: const Text('Health Trends'),
            subtitle: const Text('View your charts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/health-trends');
            },
          ),

          // Appointments
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Appointments'),
            subtitle: const Text('Manage visits'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointments - Coming soon!')),
              );
            },
          ),

          // Educational Resources
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Learn'),
            subtitle: const Text('Articles & videos'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Educational content - Coming soon!')),
              );
            },
          ),

          const Divider(),

          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile - Coming soon!')),
              );
            },
          ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming soon!')),
              );
            },
          ),

          const Divider(),

          // Help & Support
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help - Coming soon!')),
              );
            },
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About MamaCare'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),

          SizedBox(height: 16.h),

          // Footer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: [
                Text(
                  'MamaCare Butler',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Digital Maternal Health Services',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About MamaCare Butler'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MamaCare Butler is an AI-powered maternal health companion designed to support expectant mothers throughout their pregnancy journey.',
              ),
              SizedBox(height: 12.h),
              const Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Kick counter & tracking'),
              const Text('• Medication reminders'),
              const Text('• Weekly health check-ins'),
              const Text('• Ultrasound analysis'),
              const Text('• Emergency SOS'),
              SizedBox(height: 12.h),
              Text(
                'Powered by Serverpod & Flutter',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
                    (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}