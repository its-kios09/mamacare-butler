import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../main.dart';
import '../../services/storage_service.dart';

class KickCounterScreen extends StatefulWidget {
  const KickCounterScreen({super.key});

  @override
  State<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends State<KickCounterScreen> {
  int _kickCount = 0;
  int _durationSeconds = 0;
  bool _isCounting = false;
  Timer? _timer;
  bool _isLoading = false;
  String _aiInsight = '';
  int _pregnancyWeek = 24; // TODO: Get from maternal profile
  List<Map<String, dynamic>> _recentSessions = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isCounting = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _durationSeconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isCounting = false);
  }

  void _incrementKick() {
    if (!_isCounting) {
      _startTimer();
    }
    setState(() => _kickCount++);
  }

  void _reset() {
    _stopTimer();
    setState(() {
      _kickCount = 0;
      _durationSeconds = 0;
      _isCounting = false;
    });
  }

  Future<void> _saveSession() async {
    if (_kickCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No kicks to save!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('User not logged in');

      final durationMinutes = (_durationSeconds / 60).ceil();

      await client.v1KickCounter.saveKickSession(
        userId,
        _kickCount,
        durationMinutes,
        null,
      );

      if (!mounted) return;

      // Get AI insight
      await _getAIInsight(userId);

      // Reload recent sessions
      await _loadRecentSessions();

      // Reset counter
      _reset();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Session saved!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadRecentSessions() async {
    try {
      final userId = StorageService().getUserId();
      if (userId == null) return;

      final sessions = await client.v1KickCounter.getRecentKicks(userId, 7);

      setState(() {
        _recentSessions = sessions.map((s) => {
          'kickCount': s.kickCount,
          'durationMinutes': s.durationMinutes,
          'sessionDate': s.sessionDate,
        }).toList();
      });
    } catch (e) {
      print('Error loading sessions: $e');
    }
  }

  Future<void> _getAIInsight(int userId) async {
    try {
      final insight = await client.v1KickCounter.getAIInsight(
        userId,
        _pregnancyWeek,
      );
      setState(() => _aiInsight = insight);
    } catch (e) {
      print('Error getting AI insight: $e');
    }
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kick Counter'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Instructions
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'How to Count',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '• Tap the button each time you feel movement\n'
                        '• Count 10 movements (kicks, flutters, swishes)\n'
                        '• Do this twice daily\n'
                        '• Should feel 10 movements within 2 hours',
                    style: TextStyle(fontSize: 12.sp, height: 1.5),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Counter Display
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[400]!,
                    Colors.blue[600]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  Text(
                    'Kicks Counted',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '$_kickCount',
                    style: TextStyle(
                      fontSize: 72.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _formatDuration(_durationSeconds),
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Tap Button
            GestureDetector(
              onTap: _incrementKick,
              child: Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, size: 48.sp, color: Colors.white),
                      SizedBox(height: 8.h),
                      Text(
                        'TAP',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Each Kick',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _kickCount > 0 ? _reset : null,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: Text('Reset', style: TextStyle(fontSize: 14.sp)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed:
                    _kickCount > 0 && !_isLoading ? _saveSession : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Save Session',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Gemini AI Insight
            if (_aiInsight.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[50]!, Colors.pink[50]!],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.purple[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.purple[700],
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Gemini AI Insight',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[900],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _aiInsight,
                      style: TextStyle(fontSize: 13.sp, height: 1.5),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Recent Sessions
            if (_recentSessions.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Sessions',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              ..._recentSessions.take(5).map((session) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        color: Colors.blue,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          '${session['kickCount']} kicks • ${session['durationMinutes']} mins',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimeAgo(session['sessionDate']),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}