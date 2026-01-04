import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mamacare_client/mamacare_client.dart';
import '../../constants/constant.dart';

class HealthCheckinResultScreen extends StatelessWidget {
  final HealthCheckin checkin;

  const HealthCheckinResultScreen({
    super.key,
    required this.checkin,
  });

  Color _getRiskColor() {
    switch (checkin.riskLevel.toUpperCase()) {
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

  IconData _getRiskIcon() {
    switch (checkin.riskLevel.toUpperCase()) {
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

  String _getRiskTitle() {
    switch (checkin.riskLevel.toUpperCase()) {
      case 'LOW':
        return 'Everything Looks Good';
      case 'MEDIUM':
        return 'Please Monitor Closely';
      case 'HIGH':
        return 'Immediate Attention Needed';
      default:
        return 'Assessment Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Health Assessment'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Risk Level Card
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [riskColor, riskColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: riskColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _getRiskIcon(),
                    size: 60.sp,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _getRiskTitle(),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${checkin.riskLevel.toUpperCase()} RISK',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // AI Assessment
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: kPrimaryColor, size: 24.sp),
                      SizedBox(width: 12.w),
                      Text(
                        'AI Assessment',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    checkin.aiRiskAssessment,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Recommendations
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: kPrimaryColor, size: 24.sp),
                      SizedBox(width: 12.w),
                      Text(
                        'Recommendations',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    checkin.recommendations,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Measurements Summary (if provided)
            if (checkin.systolicBP != null || checkin.diastolicBP != null || checkin.weight != null)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monitor_heart, color: kPrimaryColor, size: 24.sp),
                        SizedBox(width: 12.w),
                        Text(
                          'Your Measurements',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (checkin.systolicBP != null && checkin.diastolicBP != null)
                          _buildMeasurementItem(
                            Icons.favorite,
                            'Blood Pressure',
                            '${checkin.systolicBP}/${checkin.diastolicBP}',
                            'mmHg',
                            Colors.red,
                          ),
                        if (checkin.weight != null)
                          _buildMeasurementItem(
                            Icons.monitor_weight,
                            'Weight',
                            checkin.weight!.toStringAsFixed(1),
                            'kg',
                            Colors.blue,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16.h),

            // Week Info
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: kPrimaryColor, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'Week ${checkin.pregnancyWeek} Check-in',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${checkin.checkInDate.day}/${checkin.checkInDate.month}/${checkin.checkInDate.year}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // High Risk Warning
            if (checkin.riskLevel.toUpperCase() == 'HIGH')
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: Colors.red, size: 28.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need Immediate Help?',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Contact your healthcare provider or emergency services immediately.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (checkin.riskLevel.toUpperCase() == 'HIGH')
              SizedBox(height: 16.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: Icon(Icons.home, size: 20.sp),
                    label: Text('Go Home', style: TextStyle(fontSize: 14.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementItem(
      IconData icon,
      String label,
      String value,
      String unit,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: color, size: 28.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(width: 4.w),
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}