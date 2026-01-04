import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mamacare_client/mamacare_client.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/storage_service.dart';
import '../../constants/constant.dart';
import 'health_checkin_result_screen.dart';

class HealthCheckinHistoryScreen extends StatefulWidget {
  const HealthCheckinHistoryScreen({super.key});

  @override
  State<HealthCheckinHistoryScreen> createState() => _HealthCheckinHistoryScreenState();
}

class _HealthCheckinHistoryScreenState extends State<HealthCheckinHistoryScreen> {
  List<HealthCheckin> _checkins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      print('📋 Loading check-in history for user $userId');

      final history = await client.v1HealthCheckin.getCheckinHistory(userId, limit: 20);

      print('✅ Loaded ${history.length} check-ins');

      setState(() {
        _checkins = history;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading history: $e');
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading history: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return Icons.check_circle;
      case 'MEDIUM':
        return Icons.warning_amber;
      case 'HIGH':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Check-in History'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 3),
            SizedBox(height: 16.h),
            Text(
              'Loading your check-ins...',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : _checkins.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: _checkins.length,
          itemBuilder: (context, index) {
            final checkin = _checkins[index];
            return _buildCheckinCard(checkin);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20.h),
          Text(
            'No Check-ins Yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Complete your first weekly\nhealth check-in to see it here',
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
            label: const Text('Start Check-in'),
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

  Widget _buildCheckinCard(HealthCheckin checkin) {
    final riskColor = _getRiskColor(checkin.riskLevel);
    final riskIcon = _getRiskIcon(checkin.riskLevel);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: riskColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HealthCheckinResultScreen(checkin: checkin),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(riskIcon, color: riskColor, size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Week ${checkin.pregnancyWeek} Check-in',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            DateFormat('MMM dd, yyyy - HH:mm').format(checkin.checkInDate),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: riskColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        checkin.riskLevel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 12.h),

                // Quick Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (checkin.systolicBP != null && checkin.diastolicBP != null)
                      _buildQuickStat(
                        Icons.favorite,
                        'BP',
                        '${checkin.systolicBP}/${checkin.diastolicBP}',
                        Colors.red,
                      ),
                    if (checkin.weight != null)
                      _buildQuickStat(
                        Icons.monitor_weight,
                        'Weight',
                        '${checkin.weight!.toStringAsFixed(1)} kg',
                        Colors.blue,
                      ),
                    _buildQuickStat(
                      Icons.assignment,
                      'Symptoms',
                      _countSymptoms(checkin).toString(),
                      kPrimaryColor,
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // AI Preview
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.psychology, color: kPrimaryColor, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          checkin.aiRiskAssessment.length > 80
                              ? '${checkin.aiRiskAssessment.substring(0, 80)}...'
                              : checkin.aiRiskAssessment,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // View Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward, color: kPrimaryColor, size: 16.sp),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  int _countSymptoms(HealthCheckin checkin) {
    int count = 0;
    if (checkin.hasSevereHeadache) count++;
    if (checkin.hasVisionChanges) count++;
    if (checkin.hasAbdominalPain) count++;
    if (checkin.hasSwelling) count++;
    if (checkin.hasReducedFetalMovement) count++;
    if (checkin.hasVaginalBleeding) count++;
    if (checkin.hasFluidLeakage) count++;
    if (checkin.hasContractions) count++;
    return count;
  }
}