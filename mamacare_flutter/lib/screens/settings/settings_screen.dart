import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/notification_service.dart';
import '../../constants/constant.dart';
import 'reminders_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _ultrasoundEnabled = true;
  bool _checkinEnabled = true;
  bool _kickCounterEnabled = true;
  bool _medicationEnabled = true;

  int _pendingReminders = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      final enabled = await notificationService.areNotificationsEnabled();
      final ultrasound = await notificationService.isNotificationTypeEnabled(NotificationType.ultrasound);
      final checkin = await notificationService.isNotificationTypeEnabled(NotificationType.dailyCheckin);
      final kickCounter = await notificationService.isNotificationTypeEnabled(NotificationType.kickCounter);
      final medication = await notificationService.isNotificationTypeEnabled(NotificationType.medication);
      final pending = await notificationService.getPendingRemindersCount();

      setState(() {
        _notificationsEnabled = enabled;
        _ultrasoundEnabled = ultrasound;
        _checkinEnabled = checkin;
        _kickCounterEnabled = kickCounter;
        _medicationEnabled = medication;
        _pendingReminders = pending;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading settings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    try {
      final notificationService = NotificationService();

      if (value) {
        final hasPermission = await notificationService.requestPermission();
        if (!hasPermission) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please enable notifications in your device settings'),
              backgroundColor: kPrimaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          );
          return;
        }

        // Schedule default reminders
        await notificationService.scheduleDailyCheckin();
        await notificationService.scheduleKickCounterReminders();
      } else {
        // Cancel all when disabled
        await notificationService.cancelAllReminders();
      }

      await notificationService.setNotificationsEnabled(value);
      setState(() => _notificationsEnabled = value);

      await _loadSettings(); // Refresh counts

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? '✅ Notifications enabled' : '🔕 Notifications disabled',
            ),
            backgroundColor: kPrimaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      }
    } catch (e) {
      print('❌ Error toggling notifications: $e');
    }
  }

  Future<void> _toggleNotificationType(NotificationType type, bool value) async {
    if (!_notificationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enable notifications first'),
          backgroundColor: kPrimaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
      return;
    }

    try {
      final notificationService = NotificationService();

      if (value) {
        // Schedule based on type
        switch (type) {
          case NotificationType.ultrasound:
          // These are scheduled individually when user accepts AI recommendation
            break;
          case NotificationType.dailyCheckin:
            await notificationService.scheduleDailyCheckin();
            break;
          case NotificationType.kickCounter:
            await notificationService.scheduleKickCounterReminders();
            break;
          case NotificationType.medication:
          // These are scheduled individually when user adds medication
            break;
        }
      } else {
        // Cancel specific type
        await notificationService.cancelRemindersByType(type);
      }

      await notificationService.setNotificationTypeEnabled(type, value);

      // Update state
      setState(() {
        switch (type) {
          case NotificationType.ultrasound:
            _ultrasoundEnabled = value;
            break;
          case NotificationType.dailyCheckin:
            _checkinEnabled = value;
            break;
          case NotificationType.kickCounter:
            _kickCounterEnabled = value;
            break;
          case NotificationType.medication:
            _medicationEnabled = value;
            break;
        }
      });

      await _loadSettings(); // Refresh counts

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? '✅ ${_getTypeName(type)} enabled' : '🔕 ${_getTypeName(type)} disabled',
            ),
            backgroundColor: kPrimaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      }
    } catch (e) {
      print('❌ Error toggling ${type.name}: $e');
    }
  }

  String _getTypeName(NotificationType type) {
    switch (type) {
      case NotificationType.ultrasound:
        return 'Ultrasound reminders';
      case NotificationType.dailyCheckin:
        return 'Weekly check-ins';
      case NotificationType.kickCounter:
        return 'Kick counter';
      case NotificationType.medication:
        return 'Medication reminders';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Header Card
          _buildHeaderCard(),
          SizedBox(height: 24.h),

          // Master Toggle
          _buildSectionTitle('Notifications'),
          SizedBox(height: 12.h),
          _buildMasterToggle(),

          if (_notificationsEnabled) ...[
            SizedBox(height: 24.h),

            // Notification Types
            _buildSectionTitle('Reminder Types'),
            SizedBox(height: 12.h),
            _buildNotificationsList(),

            if (_pendingReminders > 0) ...[
              SizedBox(height: 24.h),
              _buildActiveRemindersCard(),
            ],
          ],

          SizedBox(height: 24.h),

          // App Info
          _buildSectionTitle('About'),
          SizedBox(height: 12.h),
          _buildAboutCard(),

          SizedBox(height: 16.h),
          _buildTimezoneInfo(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.settings, color: Colors.white, size: 32.sp),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Customize your MamaCare experience',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMasterToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _notificationsEnabled ? kPrimaryColor.withOpacity(0.3) : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
        activeColor: kPrimaryColor,
        title: Text(
          'Enable Notifications',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _notificationsEnabled ? 'All reminders active' : 'Tap to enable reminders',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        secondary: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: _notificationsEnabled
                ? kPrimaryColor.withOpacity(0.1)
                : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
            color: _notificationsEnabled ? kPrimaryColor : Colors.grey[600],
            size: 24.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildNotificationTile(
            icon: Icons.medical_information,
            title: 'Ultrasound Reminders',
            subtitle: 'AI-recommended scans',
            value: _ultrasoundEnabled,
            type: NotificationType.ultrasound,
            isFirst: true,
          ),
          _buildDivider(),
          _buildNotificationTile(
            icon: Icons.favorite,
            title: 'Weekly Check-ins',
            subtitle: 'Every Monday at 10:00 AM',
            value: _checkinEnabled,
            type: NotificationType.dailyCheckin,
          ),
          _buildDivider(),
          _buildNotificationTile(
            icon: Icons.child_care,
            title: 'Kick Counter',
            subtitle: '10:00 AM & 8:00 PM daily',
            value: _kickCounterEnabled,
            type: NotificationType.kickCounter,
          ),
          _buildDivider(),
          _buildNotificationTile(
            icon: Icons.medication,
            title: 'Medications',
            subtitle: 'Prenatal vitamins',
            value: _medicationEnabled,
            type: NotificationType.medication,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required NotificationType type,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: (v) => _toggleNotificationType(type, v),
      activeColor: kPrimaryColor,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
      secondary: Icon(
        icon,
        color: value ? kPrimaryColor : Colors.grey[400],
        size: 24.sp,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 68.w,
      endIndent: 20.w,
    );
  }

  Widget _buildActiveRemindersCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.schedule, color: kPrimaryColor, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Reminders',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$_pendingReminders upcoming reminder${_pendingReminders == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: kPrimaryColor, size: 18.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: kPrimaryColor, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'MamaCare Butler',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'AI-powered maternal health companion for Kenyan mothers',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimezoneInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: kPrimaryColor, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'East Africa Time (EAT) - Nairobi 🇰🇪',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}