import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../constants/constant.dart';
import '../../services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _isLoading = true;
  List<PendingNotificationRequest> _ultrasoundReminders = [];
  List<PendingNotificationRequest> _checkinReminders = [];
  List<PendingNotificationRequest> _kickCounterReminders = [];
  List<PendingNotificationRequest> _medicationReminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);

    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      final ultrasound = await notificationService.getPendingRemindersByType(NotificationType.ultrasound);
      final checkin = await notificationService.getPendingRemindersByType(NotificationType.dailyCheckin);
      final kickCounter = await notificationService.getPendingRemindersByType(NotificationType.kickCounter);
      final medication = await notificationService.getPendingRemindersByType(NotificationType.medication);

      setState(() {
        _ultrasoundReminders = ultrasound;
        _checkinReminders = checkin;
        _kickCounterReminders = kickCounter;
        _medicationReminders = medication;
        _isLoading = false;
      });

      print('✅ Loaded reminders: U=${ultrasound.length}, C=${checkin.length}, K=${kickCounter.length}, M=${medication.length}');
    } catch (e) {
      print('❌ Error loading reminders: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelReminder(int notificationId, NotificationType type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Cancel Reminder?'),
        content: const Text('Are you sure you want to cancel this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Reminder'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final notificationService = NotificationService();

      if (type == NotificationType.ultrasound) {
        final week = notificationId - 1000;
        await notificationService.cancelUltrasoundReminder(week);
      } else {
        await notificationService.cancelMedicationReminder(notificationId);
      }

      await _loadReminders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ Error cancelling reminder: $e');
    }
  }

  Future<void> _cancelAllReminders() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 24.sp),
            SizedBox(width: 12.w),
            const Text('Cancel All?'),
          ],
        ),
        content: Text(
          'This will cancel all ${_getTotalCount()} active reminders. Are you sure?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep All'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final notificationService = NotificationService();
      await notificationService.cancelAllReminders();
      await _loadReminders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All reminders cancelled'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error cancelling all reminders: $e');
    }
  }

  int _getTotalCount() {
    return _ultrasoundReminders.length +
        _checkinReminders.length +
        _kickCounterReminders.length +
        _medicationReminders.length;
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _getTotalCount();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Active Reminders'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (totalCount > 0)
            IconButton(
              icon: Icon(Icons.delete_sweep, size: 24.sp),
              onPressed: _cancelAllReminders,
              tooltip: 'Cancel All',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : totalCount == 0
          ? _buildEmptyState()
          : ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Summary Card
          _buildSummaryCard(totalCount),
          SizedBox(height: 24.h),

          // Ultrasound Reminders
          if (_ultrasoundReminders.isNotEmpty) ...[
            _buildSectionHeader('Ultrasound Scans', _ultrasoundReminders.length, kPrimaryColor),
            SizedBox(height: 12.h),
            ..._ultrasoundReminders.map((r) => _buildUltrasoundReminderCard(r)),
            SizedBox(height: 24.h),
          ],

          // Check-in Reminders
          if (_checkinReminders.isNotEmpty) ...[
            _buildSectionHeader('Weekly Check-ins', _checkinReminders.length, Colors.red),
            SizedBox(height: 12.h),
            ..._checkinReminders.map((r) => _buildCheckinReminderCard(r)),
            SizedBox(height: 24.h),
          ],

          // Kick Counter Reminders
          if (_kickCounterReminders.isNotEmpty) ...[
            _buildSectionHeader('Kick Counter', _kickCounterReminders.length, Colors.purple),
            SizedBox(height: 12.h),
            ..._kickCounterReminders.map((r) => _buildKickCounterReminderCard(r)),
            SizedBox(height: 24.h),
          ],

          // Medication Reminders
          if (_medicationReminders.isNotEmpty) ...[
            _buildSectionHeader('Medications', _medicationReminders.length, Colors.orange),
            SizedBox(height: 12.h),
            ..._medicationReminders.map((r) => _buildMedicationReminderCard(r)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int total) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor.withOpacity(0.1), Colors.pink[50]!],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active, color: Colors.white, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Reminders',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$total Upcoming',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            _getIconForSection(title),
            color: color,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForSection(String title) {
    switch (title) {
      case 'Ultrasound Scans':
        return Icons.medical_information;
      case 'Weekly Check-ins':
        return Icons.favorite;
      case 'Kick Counter':
        return Icons.child_care;
      case 'Medications':
        return Icons.medication;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildUltrasoundReminderCard(PendingNotificationRequest reminder) {
    final week = reminder.id - 1000;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.medical_information, color: kPrimaryColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Week $week Ultrasound',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  reminder.body ?? 'Routine follow-up scan',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.orange, size: 24.sp),
            onPressed: () => _cancelReminder(reminder.id, NotificationType.ultrasound),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinReminderCard(PendingNotificationRequest reminder) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite, color: Colors.red, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Health Check-in',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Every Monday at 10:00 AM',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.repeat, color: Colors.red, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildKickCounterReminderCard(PendingNotificationRequest reminder) {
    final isMorning = reminder.id == 3000;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.child_care, color: Colors.purple, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMorning ? 'Morning Kick Count' : 'Evening Kick Count',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isMorning ? 'Daily at 10:00 AM' : 'Daily at 8:00 PM',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.repeat, color: Colors.purple, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildMedicationReminderCard(PendingNotificationRequest reminder) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.medication, color: Colors.orange, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title ?? 'Medication',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  reminder.body ?? 'Take your medication',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.orange, size: 24.sp),
            onPressed: () => _cancelReminder(reminder.id, NotificationType.medication),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20.h),
          Text(
            'No Active Reminders',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Set reminders from ultrasound scans\nor enable them in settings',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.settings, size: 20.sp),
            label: const Text('Go to Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}