import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

enum NotificationType {
  ultrasound,
  dailyCheckin,
  kickCounter,
  medication,
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification channel IDs
  static const String _ultrasoundChannel = 'ultrasound_reminders';
  static const String _checkinChannel = 'daily_checkins';
  static const String _kickCounterChannel = 'kick_counter_reminders';
  static const String _medicationChannel = 'medication_reminders';

  /// Initialize notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Nairobi'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;

    print('✅ Notification service initialized');
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    // Request notification permission
    if (!await Permission.notification.isGranted) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        print('❌ Notification permission denied');
        return false;
      }
    }

    // Request exact alarm permission (Android 12+)
    try {
      if (!await Permission.scheduleExactAlarm.isGranted) {
        final status = await Permission.scheduleExactAlarm.request();
        if (!status.isGranted) {
          print('⚠️ Exact alarm permission denied - notifications may not be precise');
          // Don't return false - allow app to continue with inexact alarms
        }
      }
    } catch (e) {
      print('⚠️ Error requesting exact alarm permission: $e');
      // Continue anyway - older Android versions don't have this permission
    }

    print('✅ Notification permissions granted');
    return true;
  }

  /// Check if exact alarm permission is granted
  Future<bool> _hasExactAlarmPermission() async {
    try {
      return await Permission.scheduleExactAlarm.isGranted;
    } catch (e) {
      print('⚠️ Cannot check exact alarm permission: $e');
      return false; // Default to inexact if we can't check
    }
  }

  /// Check if notifications are enabled globally
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  /// Set notifications enabled/disabled globally
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    print('🔔 Notifications ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Check if specific notification type is enabled
  Future<bool> isNotificationTypeEnabled(NotificationType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${type.name}_notifications_enabled';
    return prefs.getBool(key) ?? true; // Default to true
  }

  /// Set specific notification type enabled/disabled
  Future<void> setNotificationTypeEnabled(NotificationType type, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${type.name}_notifications_enabled';
    await prefs.setBool(key, enabled);
    print('🔔 ${type.name} notifications ${enabled ? 'enabled' : 'disabled'}');
  }

  // ==================== ULTRASOUND REMINDERS ====================

  /// Schedule ultrasound scan reminder
  Future<bool> scheduleUltrasoundReminder({
    required int scanWeek,
    required DateTime scanDate,
    String? reason,
  }) async {
    try {
      if (!await _canSchedule(NotificationType.ultrasound)) return false;

      // Create scheduled date at 9:00 AM
      var scheduledDate = DateTime(
        scanDate.year,
        scanDate.month,
        scanDate.day,
        9, // 9:00 AM
        0,
      );

      // If date is in the past, schedule for tomorrow at 9 AM instead
      final now = DateTime.now();
      if (scheduledDate.isBefore(now)) {
        scheduledDate = now.add(const Duration(days: 1));
        scheduledDate = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          9,
          0,
        );
        print('⚠️ Scan date was in past, rescheduled for tomorrow at 9 AM');
      }

      final notificationId = 1000 + scanWeek; // 1000-1999 range for ultrasound

      // Determine schedule mode based on exact alarm permission
      final hasExactAlarmPermission = await _hasExactAlarmPermission();
      final scheduleMode = hasExactAlarmPermission
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      if (!hasExactAlarmPermission) {
        print('⚠️ Using inexact alarm mode - notification may be delayed');
      }

      await _notifications.zonedSchedule(
        notificationId,
        '📅 Ultrasound Scan Reminder',
        'Week $scanWeek ultrasound recommended! ${reason ?? "Routine follow-up"}',
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _ultrasoundChannel,
            'Ultrasound Reminders',
            channelDescription: 'Reminders for scheduled ultrasound scans',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ Ultrasound reminder scheduled for $scheduledDate (Week $scanWeek)');
      return true;

    } catch (e) {
      print('❌ Error scheduling ultrasound reminder: $e');
      return false;
    }
  }

  /// Cancel ultrasound reminder
  Future<void> cancelUltrasoundReminder(int scanWeek) async {
    final notificationId = 1000 + scanWeek;
    await _notifications.cancel(notificationId);
    print('🗑️ Cancelled ultrasound reminder for week $scanWeek');
  }

  // ==================== DAILY CHECK-IN REMINDERS ====================

  /// Schedule weekly check-in reminder (every Monday at 10:00 AM)
  Future<bool> scheduleDailyCheckin({
    int hour = 10,
    int minute = 0,
  }) async {
    try {
      if (!await _canSchedule(NotificationType.dailyCheckin)) return false;

      // Schedule for every Monday
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Find next Monday
      while (scheduledDate.weekday != DateTime.monday || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Determine schedule mode
      final hasExactAlarmPermission = await _hasExactAlarmPermission();
      final scheduleMode = hasExactAlarmPermission
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      await _notifications.zonedSchedule(
        2000, // ID for weekly check-in
        '💗 Weekly Health Check-in',
        'How are you feeling this week? Complete your health check-in with AI.',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _checkinChannel,
            'Weekly Check-ins',
            channelDescription: 'Weekly health assessment reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ Weekly check-in scheduled for every Monday at $hour:${minute.toString().padLeft(2, '0')}');
      return true;

    } catch (e) {
      print('❌ Error scheduling check-in: $e');
      return false;
    }
  }

  /// Cancel daily check-in reminder
  Future<void> cancelDailyCheckin() async {
    await _notifications.cancel(2000);
    print('🗑️ Cancelled weekly check-in reminder');
  }

  // ==================== KICK COUNTER REMINDERS ====================

  /// Schedule kick counter reminders (twice daily)
  Future<bool> scheduleKickCounterReminders({
    int morningHour = 10,
    int eveningHour = 20,
  }) async {
    try {
      if (!await _canSchedule(NotificationType.kickCounter)) return false;

      // Determine schedule mode
      final hasExactAlarmPermission = await _hasExactAlarmPermission();
      final scheduleMode = hasExactAlarmPermission
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      // Morning reminder
      final now = tz.TZDateTime.now(tz.local);
      var morningTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        morningHour,
        0,
      );

      if (morningTime.isBefore(now)) {
        morningTime = morningTime.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        3000, // Morning kick counter
        '👶 Morning Kick Count',
        'Time to count your baby\'s movements! Track 10 kicks.',
        morningTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _kickCounterChannel,
            'Kick Counter',
            channelDescription: 'Daily kick counting reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Evening reminder
      var eveningTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        eveningHour,
        0,
      );

      if (eveningTime.isBefore(now)) {
        eveningTime = eveningTime.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        3001, // Evening kick counter
        '👶 Evening Kick Count',
        'Time for your evening kick count! Track baby\'s movements.',
        eveningTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _kickCounterChannel,
            'Kick Counter',
            channelDescription: 'Daily kick counting reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ Kick counter reminders scheduled: $morningHour:00 & $eveningHour:00');
      return true;

    } catch (e) {
      print('❌ Error scheduling kick counter reminders: $e');
      return false;
    }
  }

  /// Cancel kick counter reminders
  Future<void> cancelKickCounterReminders() async {
    await _notifications.cancel(3000);
    await _notifications.cancel(3001);
    print('🗑️ Cancelled kick counter reminders');
  }

  // ==================== MEDICATION REMINDERS ====================

  /// Schedule medication reminder
  Future<bool> scheduleMedicationReminder({
    required String medicationName,
    required int hour,
    required int minute,
    int? customId,
  }) async {
    try {
      if (!await _canSchedule(NotificationType.medication)) return false;

      final notificationId = customId ?? (4000 + hour * 100 + minute); // 4000-4999 range

      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      // Determine schedule mode
      final hasExactAlarmPermission = await _hasExactAlarmPermission();
      final scheduleMode = hasExactAlarmPermission
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      await _notifications.zonedSchedule(
        notificationId,
        '💊 Medication Reminder',
        'Time to take your $medicationName',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _medicationChannel,
            'Medications',
            channelDescription: 'Medication and supplement reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ Medication reminder scheduled: $medicationName at $hour:${minute.toString().padLeft(2, '0')}');
      return true;

    } catch (e) {
      print('❌ Error scheduling medication reminder: $e');
      return false;
    }
  }

  /// Cancel medication reminder
  Future<void> cancelMedicationReminder(int notificationId) async {
    await _notifications.cancel(notificationId);
    print('🗑️ Cancelled medication reminder $notificationId');
  }

  // ==================== UTILITY METHODS ====================

  /// Check if we can schedule for this notification type
  Future<bool> _canSchedule(NotificationType type) async {
    // Check global setting
    final globalEnabled = await areNotificationsEnabled();
    if (!globalEnabled) {
      print('⚠️ Notifications are disabled globally');
      return false;
    }

    // Check type-specific setting
    final typeEnabled = await isNotificationTypeEnabled(type);
    if (!typeEnabled) {
      print('⚠️ ${type.name} notifications are disabled');
      return false;
    }

    // Request permission
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      print('⚠️ Notification permission denied');
      return false;
    }

    return true;
  }

  /// Get pending notifications count
  Future<int> getPendingRemindersCount() async {
    final pending = await _notifications.pendingNotificationRequests();
    return pending.length;
  }

  /// Get pending reminders by type
  Future<List<PendingNotificationRequest>> getPendingRemindersByType(NotificationType type) async {
    final pending = await _notifications.pendingNotificationRequests();

    // Filter by ID range
    final int minId;
    final int maxId;

    switch (type) {
      case NotificationType.ultrasound:
        minId = 1000;
        maxId = 1999;
        break;
      case NotificationType.dailyCheckin:
        minId = 2000;
        maxId = 2999;
        break;
      case NotificationType.kickCounter:
        minId = 3000;
        maxId = 3999;
        break;
      case NotificationType.medication:
        minId = 4000;
        maxId = 4999;
        break;
    }

    return pending.where((n) => n.id >= minId && n.id <= maxId).toList();
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  /// Cancel all reminders of a specific type
  Future<void> cancelRemindersByType(NotificationType type) async {
    final pending = await getPendingRemindersByType(type);
    for (final notification in pending) {
      await _notifications.cancel(notification.id);
    }
    print('🗑️ Cancelled all ${type.name} reminders (${pending.length} total)');
  }
}