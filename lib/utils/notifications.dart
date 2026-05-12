import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Notification management for HouseCycle reminders.
class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// Initialize notifications.
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@app_icon');
    const iosSettings = DarwinInitializationSettings();

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  /// Schedule reminder notifications.
  /// Friday 6PM, Saturday 2PM, Sunday 9AM, Sunday 6PM, Sunday 11PM.
  static Future<void> scheduleReminders() async {
    // Friday 6 PM (18:00)
    await _scheduleWeeklyNotification(
      id: 1,
      title: 'HouseCycle Reminder',
      body: 'Your task awaits. Weekend is coming!',
      weekday: DateTime.friday,
      hour: 18,
      minute: 0,
    );

    // Saturday 2 PM (14:00)
    await _scheduleWeeklyNotification(
      id: 2,
      title: 'HouseCycle Reminder',
      body: 'Saturday afternoon — time to get it done!',
      weekday: DateTime.saturday,
      hour: 14,
      minute: 0,
    );

    // Sunday 9 AM (09:00)
    await _scheduleWeeklyNotification(
      id: 3,
      title: 'HouseCycle Reminder',
      body: 'Last day! Submit your completion by tonight.',
      weekday: DateTime.sunday,
      hour: 9,
      minute: 0,
    );

    // Sunday 6 PM (18:00)
    await _scheduleWeeklyNotification(
      id: 4,
      title: 'HouseCycle Urgent',
      body: 'Final hours! Get it submitted now.',
      weekday: DateTime.sunday,
      hour: 18,
      minute: 0,
    );

    // Sunday 11 PM (23:00) - overdue reminder
    await _scheduleWeeklyNotification(
      id: 5,
      title: 'HouseCycle Overdue',
      body: 'Task is now overdue. Leader will handle it.',
      weekday: DateTime.sunday,
      hour: 23,
      minute: 0,
    );
  }

  /// Schedule a weekly notification.
  static Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    // Calculate next occurrence of the target weekday and time
    final now = tz.TZDateTime.now(tz.local);
    var scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Adjust to target weekday
    int daysAhead = weekday - scheduleDate.weekday;
    if (daysAhead <= 0) {
      daysAhead += 7;
    }
    scheduleDate = scheduleDate.add(Duration(days: daysAhead));

    // If the time has already passed today, schedule for next week
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 7));
    }

    const androidDetails = AndroidNotificationDetails(
      'housecycle_reminders',
      'HouseCycle Reminders',
      channelDescription: 'Weekly task reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduleDate,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Show instant notification.
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'housecycle_instant',
      'HouseCycle Instant',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  /// Cancel all notifications.
  static Future<void> cancelAll() => _notifications.cancelAll();
}
