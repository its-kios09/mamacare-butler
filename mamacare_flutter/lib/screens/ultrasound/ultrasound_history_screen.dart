import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import '../../constants/constant.dart';
import '../../main.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../settings/settings_screen.dart';

class UltrasoundHistoryScreen extends StatefulWidget {
  const UltrasoundHistoryScreen({super.key});

  @override
  State<UltrasoundHistoryScreen> createState() =>
      _UltrasoundHistoryScreenState();
}

class _UltrasoundHistoryScreenState extends State<UltrasoundHistoryScreen> {
  List<dynamic> _scans = [];
  bool _isLoading = true;
  bool _isAnalyzingHistory = false;
  String? _historyAnalysis;
  Set<int> _activeReminders = {}; // Track which weeks have reminders

  @override
  void initState() {
    super.initState();
    _loadScans();
    _loadActiveReminders();
  }

  Future<void> _loadScans() async {
    setState(() => _isLoading = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      print('📂 Loading ultrasound scans for user $userId');

      final scans = await client.v1Ultrasound.getUserScans(userId);

      print('✅ Loaded ${scans.length} scans');

      setState(() {
        _scans = scans;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading scans: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading scans: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadActiveReminders() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      final pending = await notificationService
          .getPendingRemindersByType(NotificationType.ultrasound);

      setState(() {
        // Extract week numbers from notification IDs (ID = 1000 + week)
        _activeReminders = pending.map((n) => n.id - 1000).toSet();
      });

      print('✅ Loaded ${_activeReminders.length} active ultrasound reminders');
    } catch (e) {
      print('❌ Error loading reminders: $e');
    }
  }

  bool _hasReminder(int? scanWeek) {
    if (scanWeek == null) return false;
    return _activeReminders.contains(scanWeek);
  }

  Future<void> _analyzeHistory() async {
    if (_scans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No scans to analyze yet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAnalyzingHistory = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      print('📊 Requesting AI analysis of ${_scans.length} scans...');

      final analysis = await client.v1Ultrasound.analyzeHistory(userId);

      print('✅ Received AI analysis: ${analysis.length} characters');

      setState(() {
        _historyAnalysis = analysis;
        _isAnalyzingHistory = false;
      });

      _showAnalysisDialog();
    } catch (e) {
      print('❌ Error analyzing history: $e');
      setState(() => _isAnalyzingHistory = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing history: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAnalysisDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          constraints: BoxConstraints(maxHeight: 600.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 28.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'AI History Analysis',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Text(
                    _historyAnalysis ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Got it', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewFullImage(Uint8List imageBytes, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: PhotoView(
            imageProvider: MemoryImage(imageBytes),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  void _setReminder(dynamic scan) {
    if (scan.nextScanWeek == null) return;

    final hasReminder = _hasReminder(scan.nextScanWeek);

    if (hasReminder) {
      // Show cancel confirmation
      _showCancelReminderDialog(scan);
    } else {
      // Show set reminder dialog
      _showSetReminderDialog(scan);
    }
  }

  void _showSetReminderDialog(dynamic scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: kPrimaryColor, size: 24.sp),
            SizedBox(width: 12.w),
            const Text('AI Recommendation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 20.sp, color: kPrimaryColor),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'AI Recommendation',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Based on your ultrasound analysis, AI recommends your next scan at:',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: kPrimaryColor, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week ${scan.nextScanWeek}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                        if (scan.nextScanDate != null)
                          Text(
                            DateFormat('MMM dd, yyyy')
                                .format(scan.nextScanDate),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 18.sp, color: Colors.blue[700]),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'You can choose to accept or decline this recommendation',
                      style:
                          TextStyle(fontSize: 12.sp, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Decline',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _saveReminder(scan);
            },
            icon: Icon(Icons.check, size: 18.sp),
            label: Text('Accept & Set Reminder',
                style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelReminderDialog(dynamic scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.notifications_off, color: Colors.orange, size: 24.sp),
            SizedBox(width: 12.w),
            const Text('Cancel Reminder?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have an active reminder for:',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.orange, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week ${scan.nextScanWeek} Ultrasound',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                        if (scan.nextScanDate != null)
                          Text(
                            DateFormat('MMM dd, yyyy')
                                .format(scan.nextScanDate),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Would you like to cancel this reminder?',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Reminder',
                style: TextStyle(fontSize: 14.sp, color: kPrimaryColor)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _cancelReminder(scan);
            },
            icon: Icon(Icons.cancel, size: 18.sp),
            label: Text('Cancel Reminder', style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveReminder(dynamic scan) async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      final success = await notificationService.scheduleUltrasoundReminder(
        scanWeek: scan.nextScanWeek!,
        scanDate: scan.nextScanDate ?? DateTime.now().add(Duration(days: 28)),
        reason: 'Routine follow-up scan',
      );

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(Icons.settings, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Please enable notifications in Settings first',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ));
        return;
      }

      // Reload active reminders
      await _loadActiveReminders();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '✅ Reminder scheduled for Week ${scan.nextScanWeek}!\nYou\'ll be notified on ${DateFormat('MMM dd').format(scan.nextScanDate ?? DateTime.now())}',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    } catch (e) {
      print('❌ Error saving reminder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error setting reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelReminder(dynamic scan) async {
    try {
      final notificationService = NotificationService();
      await notificationService.cancelUltrasoundReminder(scan.nextScanWeek!);

      // Reload active reminders
      await _loadActiveReminders();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.cancel, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Reminder cancelled for Week ${scan.nextScanWeek}',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    } catch (e) {
      print('❌ Error cancelling reminder: $e');
    }
  }

  void _viewScanDetails(dynamic scan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _buildScanDetailsSheet(scan),
    );
  }

  Widget _buildScanDetailsSheet(dynamic scan) {
    final measurements = json.decode(scan.measurements) as Map<String, dynamic>;
    final imageBytes = base64Decode(scan.imageBase64);
    final hasReminder = _hasReminder(scan.nextScanWeek);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Scan Details',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Week ${scan.pregnancyWeek} • ${DateFormat('MMM dd, yyyy').format(scan.scanDate)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () => _viewFullImage(
                  Uint8List.fromList(imageBytes),
                  'Week ${scan.pregnancyWeek} Ultrasound',
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.memory(
                        Uint8List.fromList(imageBytes),
                        fit: BoxFit.cover,
                        height: 250.h,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      bottom: 12.w,
                      right: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in,
                                color: Colors.white, size: 16.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'Tap to enlarge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              if (measurements.isNotEmpty) ...[
                Text(
                  '📏 Measurements',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: measurements.entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              entry.value.toString(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
              Text(
                '🤖 AI Explanation',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor.withOpacity(0.05), Colors.pink[50]!],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
                ),
                child: Text(
                  scan.aiExplanation,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              if (scan.nextScanWeek != null) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: hasReminder ? Colors.green[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color:
                          hasReminder ? Colors.green[200]! : Colors.blue[200]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasReminder
                                ? Icons.notifications_active
                                : Icons.calendar_today,
                            color: hasReminder
                                ? Colors.green[700]
                                : Colors.blue[700],
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasReminder
                                      ? 'Reminder Active'
                                      : 'Next Scan Recommended',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: hasReminder
                                        ? Colors.green[900]
                                        : Colors.blue[900],
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Week ${scan.nextScanWeek}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: hasReminder
                                        ? Colors.green[700]
                                        : Colors.blue[700],
                                  ),
                                ),
                                if (scan.nextScanDate != null)
                                  Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(scan.nextScanDate),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _setReminder(scan);
                        },
                        icon: Icon(
                          hasReminder
                              ? Icons.cancel
                              : Icons.notifications_active,
                          size: 18.sp,
                        ),
                        label: Text(
                            hasReminder ? 'Cancel Reminder' : 'Set Reminder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              hasReminder ? Colors.orange : Colors.blue[700],
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Close', style: TextStyle(fontSize: 16.sp)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_scans.isNotEmpty)
            IconButton(
              icon: _isAnalyzingHistory
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.psychology, size: 24.sp),
              onPressed: _isAnalyzingHistory ? null : _analyzeHistory,
              tooltip: 'AI Analyze History',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: kPrimaryColor, strokeWidth: 3),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading your scans...',
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : _scans.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    if (_scans.length > 1) ...[
                      Container(
                        margin: EdgeInsets.all(16.w),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kPrimaryColor.withOpacity(0.1),
                              Colors.pink[50]!
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          border:
                              Border.all(color: kPrimaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome,
                                color: kPrimaryColor, size: 24.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI History Analysis',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Get AI insights on your pregnancy progress',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: kPrimaryColor.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  _isAnalyzingHistory ? null : _analyzeHistory,
                              icon: _isAnalyzingHistory
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: CircularProgressIndicator(
                                        color: kPrimaryColor,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(Icons.arrow_forward,
                                      color: kPrimaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await _loadScans();
                          await _loadActiveReminders();
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          itemCount: _scans.length,
                          itemBuilder: (context, index) {
                            final scan = _scans[index];
                            return _buildScanCard(scan);
                          },
                        ),
                      ),
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
            Icons.medical_information_outlined,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20.h),
          Text(
            'No Scans Yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Upload your first ultrasound scan\nto get started',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.add, size: 20.sp),
            label: const Text('Upload Scan'),
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

  Widget _buildScanCard(dynamic scan) {
    final measurements = json.decode(scan.measurements) as Map<String, dynamic>;
    final imageBytes = base64Decode(scan.imageBase64);
    final hasReminder = _hasReminder(scan.nextScanWeek);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewScanDetails(scan),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _viewFullImage(
                    Uint8List.fromList(imageBytes),
                    'Week ${scan.pregnancyWeek} Ultrasound',
                  ),
                  child: Hero(
                    tag: 'scan_${scan.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.memory(
                        Uint8List.fromList(imageBytes),
                        width: 80.w,
                        height: 80.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Week ${scan.pregnancyWeek}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        DateFormat('MMMM dd, yyyy').format(scan.scanDate),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${measurements.length} measurements',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (scan.nextScanWeek != null) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              hasReminder
                                  ? Icons.notifications_active
                                  : Icons.auto_awesome,
                              size: 14.sp,
                              color: hasReminder ? Colors.green : kPrimaryColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              hasReminder
                                  ? 'Reminder set: Week ${scan.nextScanWeek}'
                                  : 'AI recommends: Week ${scan.nextScanWeek}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color:
                                    hasReminder ? Colors.green : kPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
