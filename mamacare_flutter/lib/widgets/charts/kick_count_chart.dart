import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/constant.dart';

class KickCountChart extends StatefulWidget {
  final List<Map<String, dynamic>> sessions;

  const KickCountChart({
    super.key,
    required this.sessions,
  });

  @override
  State<KickCountChart> createState() => _KickCountChartState();
}

class _KickCountChartState extends State<KickCountChart> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    if (widget.sessions.isEmpty) {
      return _buildEmptyState();
    }

    // Filter sessions based on selected range
    final filteredSessions = widget.sessions.take(_selectedDays).toList();

    if (filteredSessions.isEmpty) {
      return _buildEmptyState();
    }

    // Calculate statistics
    final kickCounts = filteredSessions.map((s) => s['kickCount'] as int).toList();
    final avgKicks = (kickCounts.reduce((a, b) => a + b) / kickCounts.length).round();
    final maxKicks = kickCounts.reduce((a, b) => a > b ? a : b);
    final minKicks = kickCounts.reduce((a, b) => a < b ? a : b);

    // Determine status
    String status = 'Normal';
    Color statusColor = Colors.green;

    if (avgKicks >= 20) {
      status = 'Excellent';
      statusColor = Colors.green;
    } else if (avgKicks >= 15) {
      status = 'Good';
      statusColor = kPrimaryColor;
    } else if (avgKicks >= 10) {
      status = 'Normal';
      statusColor = Colors.orange;
    } else {
      status = 'Attention';
      statusColor = Colors.red;
    }

    // Prepare chart data
    final chartData = _prepareChartData(filteredSessions);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.05),
            kPrimaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kick Count Trend',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${filteredSessions.length} sessions',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == 'Excellent' ? Icons.stars :
                      status == 'Good' ? Icons.thumb_up :
                      status == 'Normal' ? Icons.check_circle :
                      Icons.warning,
                      color: statusColor,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Time Range Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTimeRangeChip('7D', 7),
                SizedBox(width: 8.w),
                _buildTimeRangeChip('2W', 14),
                SizedBox(width: 8.w),
                _buildTimeRangeChip('1M', 30),
                SizedBox(width: 8.w),
                _buildTimeRangeChip('3M', 90),
                SizedBox(width: 8.w),
                _buildTimeRangeChip('All', 365),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Stats Row
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Average', '$avgKicks', kPrimaryColor, Icons.analytics),
                Container(width: 1, height: 30.h, color: Colors.grey[300]),
                _buildStat('Peak', '$maxKicks', Colors.green, Icons.arrow_upward),
                Container(width: 1, height: 30.h, color: Colors.grey[300]),
                _buildStat('Low', '$minKicks', Colors.orange, Icons.arrow_downward),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Chart
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SizedBox(
              height: 200.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200]!,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35.w,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return _getBottomTitle(value.toInt(), chartData.length);
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (chartData.length - 1).toDouble(),
                  minY: 0,
                  maxY: (maxKicks + 5).toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          kPrimaryColor,
                          kPrimaryColor.withOpacity(0.7),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: kPrimaryColor,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            kPrimaryColor.withOpacity(0.3),
                            kPrimaryColor.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Last session info
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16.sp, color: kPrimaryColor),
                SizedBox(width: 8.w),
                Text(
                  'Last: ${filteredSessions.first['kickCount']} kicks in ${filteredSessions.first['durationMinutes']} mins',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _getTimeAgo(filteredSessions.first['sessionDate']),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeChip(String label, int days) {
    final isSelected = _selectedDays == days;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDays = days);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [
            kPrimaryColor,
            kPrimaryColor.withOpacity(0.8),
          ])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<FlSpot> _prepareChartData(List<Map<String, dynamic>> sessions) {
    final reversed = sessions.reversed.toList();
    return List.generate(
      reversed.length,
          (index) => FlSpot(
        index.toDouble(),
        (reversed[index]['kickCount'] as int).toDouble(),
      ),
    );
  }

  Widget _getBottomTitle(int index, int length) {
    if (index < 0 || index >= length) return const Text('');

    final reversed = widget.sessions.take(_selectedDays).toList().reversed.toList();
    final date = reversed[index]['sessionDate'] as DateTime;

    String label;
    if (_selectedDays <= 7) {
      final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      label = labels[date.weekday - 1];
    } else if (_selectedDays <= 14) {
      label = '${date.day}/${date.month}';
    } else {
      label = index % 5 == 0 ? '${date.day}/${date.month}' : '';
    }

    return Text(
      label,
      style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(0.05),
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart, size: 64.sp, color: kPrimaryColor.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Text(
            'No Kick Data Yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start counting kicks to see\nyour beautiful trend chart!',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}