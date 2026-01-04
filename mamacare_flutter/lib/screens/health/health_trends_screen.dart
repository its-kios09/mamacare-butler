import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/storage_service.dart';
import '../../constants/constant.dart';
import '../health_checkin/health_checkin_history_screen.dart';

class HealthTrendsScreen extends StatefulWidget {
  const HealthTrendsScreen({super.key});

  @override
  State<HealthTrendsScreen> createState() => _HealthTrendsScreenState();
}

class _HealthTrendsScreenState extends State<HealthTrendsScreen> {
  bool _isLoading = true;
  List<dynamic> _checkins = [];
  List<dynamic> _kickSessions = [];
  String _selectedPeriod = '1M'; // 1W, 2W, 1M, 3M, All

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      print('📊 Loading health trends data...');

      // Load both check-ins and kick sessions
      final checkins = await client.v1HealthCheckin.getCheckinHistory(userId, limit: 50);
      final kickSessions = await client.v1KickCounter.getUserSessions(userId);

      print('✅ Loaded ${checkins.length} check-ins and ${kickSessions.length} kick sessions');

      setState(() {
        _checkins = checkins;
        _kickSessions = kickSessions;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading trends: $e');
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading trends: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> _getFilteredCheckins() {
    if (_selectedPeriod == 'All') return _checkins;

    final now = DateTime.now();
    int daysToFilter;

    switch (_selectedPeriod) {
      case '1W':
        daysToFilter = 7;
        break;
      case '2W':
        daysToFilter = 14;
        break;
      case '1M':
        daysToFilter = 30;
        break;
      case '3M':
        daysToFilter = 90;
        break;
      default:
        daysToFilter = 30;
    }

    return _checkins.where((checkin) {
      final date = checkin.checkInDate;
      return now.difference(date).inDays <= daysToFilter;
    }).toList();
  }

  List<dynamic> _getFilteredKickSessions() {
    if (_selectedPeriod == 'All') return _kickSessions;

    final now = DateTime.now();
    int daysToFilter;

    switch (_selectedPeriod) {
      case '1W':
        daysToFilter = 7;
        break;
      case '2W':
        daysToFilter = 14;
        break;
      case '1M':
        daysToFilter = 30;
        break;
      case '3M':
        daysToFilter = 90;
        break;
      default:
        daysToFilter = 30;
    }

    return _kickSessions.where((session) {
      final date = session.sessionDate;
      return now.difference(date).inDays <= daysToFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Health Trends'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history, size: 24.sp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HealthCheckinHistoryScreen(),
                ),
              );
            },
            tooltip: 'Check-in History',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 3),
            SizedBox(height: 16.h),
            Text(
              'Loading your health data...',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : (_checkins.isEmpty && _kickSessions.isEmpty)
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              _buildPeriodSelector(),

              SizedBox(height: 24.h),

              // Kick Counter Chart
              _buildKickCounterChart(),

              SizedBox(height: 24.h),

              // Blood Pressure Chart
              _buildBloodPressureChart(),

              SizedBox(height: 24.h),

              // Weight Chart
              _buildWeightChart(),

              SizedBox(height: 24.h),
            ],
          ),
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
            Icons.show_chart,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20.h),
          Text(
            'No Health Data Yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Complete check-ins and track kicks\nto see your health trends',
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
            label: const Text('Get Started'),
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

  Widget _buildPeriodSelector() {
    final periods = ['1W', '2W', '1M', '3M', 'All'];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKickCounterChart() {
    final filteredData = _getFilteredKickSessions();

    if (filteredData.isEmpty) {
      return _buildEmptyChart('Kick Counter', Icons.child_care, Colors.purple);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.child_care, color: Colors.purple, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Kick Counter',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Number of kicks per session',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.w,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30.h,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < filteredData.length) {
                          final date = filteredData[value.toInt()].sessionDate;
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              DateFormat('MM/dd').format(date),
                              style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: filteredData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.kickCount.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.purple.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodPressureChart() {
    final filteredData = _getFilteredCheckins();
    final bpData = filteredData
        .where((c) => c.systolicBP != null && c.diastolicBP != null)
        .toList();

    if (bpData.isEmpty) {
      return _buildEmptyChart('Blood Pressure', Icons.favorite, Colors.red);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Blood Pressure',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Systolic & Diastolic (mmHg)',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.w,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30.h,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < bpData.length) {
                          final date = bpData[value.toInt()].checkInDate;
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              DateFormat('MM/dd').format(date),
                              style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Systolic
                  LineChartBarData(
                    spots: bpData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.systolicBP!.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Diastolic
                  LineChartBarData(
                    spots: bpData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.diastolicBP!.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.pink,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                minY: 40,
                maxY: 180,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Systolic', Colors.red),
              SizedBox(width: 24.w),
              _buildLegendItem('Diastolic', Colors.pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    final filteredData = _getFilteredCheckins();
    final weightData = filteredData.where((c) => c.weight != null).toList();

    if (weightData.isEmpty) {
      return _buildEmptyChart('Weight', Icons.monitor_weight, Colors.blue);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_weight, color: Colors.blue, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Weight',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Weight in kilograms (kg)',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.w,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30.h,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < weightData.length) {
                          final date = weightData[value.toInt()].checkInDate;
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              DateFormat('MM/dd').format(date),
                              style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weightData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.weight!);
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildEmptyChart(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Icon(Icons.show_chart, size: 48.sp, color: Colors.grey[300]),
          SizedBox(height: 12.h),
          Text(
            'No data available for this period',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          Text(
            'Track ${title.toLowerCase()} to see trends',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}