import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicationAdherenceChart extends StatelessWidget {
  final double adherencePercentage; // 0-100
  final int daysTaken;
  final int totalDays;

  const MedicationAdherenceChart({
    super.key,
    required this.adherencePercentage,
    required this.daysTaken,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (adherencePercentage >= 90) {
      statusColor = Colors.green;
      statusText = 'Excellent';
      statusIcon = Icons.check_circle;
    } else if (adherencePercentage >= 70) {
      statusColor = Colors.orange;
      statusText = 'Good';
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.red;
      statusText = 'Needs Attention';
      statusIcon = Icons.error;
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.medication, color: Colors.green, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Medication Adherence',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Main percentage
          Row(
            children: [
              Text(
                '${adherencePercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '$daysTaken of $totalDays days',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: adherencePercentage / 100,
              minHeight: 12.h,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),

          SizedBox(height: 16.h),

          // Days visualization
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isTaken = index < daysTaken;
              return Container(
                width: 38.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: isTaken ? statusColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                    style: TextStyle(
                      color: isTaken ? Colors.white : Colors.grey[600],
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),

          if (adherencePercentage < 90) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.orange[900], size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Set daily reminders to improve adherence!',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}