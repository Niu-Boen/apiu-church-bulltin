import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SabbathReminderService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    // 初始化时区
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }

  static Future<void> scheduleSabbathReminders(
      DateTime fridaySunset, DateTime saturdaySunset) async {
    // 周五日落前1小时
    final preReminderTime = fridaySunset.subtract(const Duration(hours: 1));
    if (preReminderTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: 1,
        scheduledDate: preReminderTime,
        title: 'Sabbath is Coming',
        body:
            'The Sabbath begins at ${DateFormat('h:mm a').format(fridaySunset)}. Prepare your heart!',
      );
    }

    // 安息日开始（周五日落）
    await _scheduleNotification(
      id: 2,
      scheduledDate: fridaySunset,
      title: 'Shabbat Shalom!',
      body: 'The Sabbath has begun. Welcome this holy time with joy.',
    );

    // 安息日结束（周六日落）
    await _scheduleNotification(
      id: 3,
      scheduledDate: saturdaySunset,
      title: 'Sabbath Ends',
      body: 'May the peace of the Sabbath remain with you throughout the week.',
    );
  }

  static Future<void> _scheduleNotification({
    required int id,
    required DateTime scheduledDate,
    required String title,
    required String body,
  }) async {
    final tz.TZDateTime scheduledTZ =
        tz.TZDateTime.from(scheduledDate, tz.local);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sabbath_channel',
      'Sabbath Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
