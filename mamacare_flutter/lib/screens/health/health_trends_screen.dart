import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/charts/kick_count_chart.dart';
import '../../widgets/charts/medication_adherence_chart.dart';

class HealthTrendsScreen extends StatelessWidget {
  const HealthTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - will be replaced with real data
    final sampleKickCounts = [18, 20, 22, 24, 22, 20, 23];
    final sampleLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sampleAdherence = 85.7;
    final sampleDaysTaken = 6;
    final sampleTotalDays = 7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Trends'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Health Analytics',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Track your pregnancy health metrics',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 24.h),

            // Kick Count Chart
            KickCountChart(
              kickCounts: sampleKickCounts,
              labels: sampleLabels,
            ),

            SizedBox(height: 16.h),

            // Medication Adherence
            MedicationAdherenceChart(
              adherencePercentage: sampleAdherence,
              daysTaken: sampleDaysTaken,
              totalDays: sampleTotalDays,
            ),

            SizedBox(height: 24.h),

            // More charts coming soon
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Icon(Icons.insights, size: 48.sp, color: Colors.grey),
                  SizedBox(height: 8.h),
                  Text(
                    'More Health Insights',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Weight, BP, and more charts coming soon!',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}