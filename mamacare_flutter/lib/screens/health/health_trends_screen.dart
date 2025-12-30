import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../main.dart';
import '../../services/storage_service.dart';
import '../../widgets/charts/kick_count_chart.dart';

class HealthTrendsScreen extends StatefulWidget {
  const HealthTrendsScreen({super.key});

  @override
  State<HealthTrendsScreen> createState() => _HealthTrendsScreenState();
}

class _HealthTrendsScreenState extends State<HealthTrendsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentSessions = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) return;

      // Get last 7 days of sessions
      final sessions = await client.v1KickCounter.getRecentKicks(userId, 7);

      // Calculate stats locally instead of calling backend
      final kickCounts = sessions.map((s) => s.kickCount).toList();

      final Map<String, dynamic> localStats = kickCounts.isEmpty
          ? <String, dynamic>{}
          : <String, dynamic>{
        'totalSessions': sessions.length,
        'totalKicks': kickCounts.reduce((a, b) => a + b),
        'averageKicks': (kickCounts.reduce((a, b) => a + b) / kickCounts.length).round(),
        'minKicks': kickCounts.reduce((a, b) => a < b ? a : b),
        'maxKicks': kickCounts.reduce((a, b) => a > b ? a : b),
      };

      setState(() {
        _recentSessions = sessions.map((s) => <String, dynamic>{
          'kickCount': s.kickCount,
          'durationMinutes': s.durationMinutes,
          'sessionDate': s.sessionDate,
        }).toList();

        _stats = localStats;
        _isLoading = false;
      });

      print('✅ Loaded ${_recentSessions.length} sessions');

    } catch (e, stackTrace) {
      print('❌ Error loading data: $e');
      print('Stack: $stackTrace');
      setState(() => _isLoading = false);
    }
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Trends'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kick Count Chart
              KickCountChart(sessions: _recentSessions),

              SizedBox(height: 24.h),

              // Statistics Card
              if (_stats.isNotEmpty && _stats['totalSessions'] > 0) ...[
                Text(
                  'Statistics (Last 7 Days)',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        'Total Sessions',
                        '${_stats['totalSessions']}',
                        Icons.event,
                      ),
                      Divider(height: 24.h),
                      _buildStatRow(
                        'Total Kicks',
                        '${_stats['totalKicks']}',
                        Icons.directions_walk,
                      ),
                      Divider(height: 24.h),
                      _buildStatRow(
                        'Average Kicks',
                        '${_stats['averageKicks']}',
                        Icons.trending_up,
                      ),
                      Divider(height: 24.h),
                      _buildStatRow(
                        'Range',
                        '${_stats['minKicks']} - ${_stats['maxKicks']}',
                        Icons.straighten,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 24.h),

              // Coming Soon
              Text(
                'More Charts Coming Soon',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              _buildComingSoonCard('Medication Adherence'),
              SizedBox(height: 8.h),
              _buildComingSoonCard('Weight Tracking'),
              SizedBox(height: 8.h),
              _buildComingSoonCard('Blood Pressure'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonCard(String title) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_empty, color: Colors.grey[400], size: 24.sp),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}