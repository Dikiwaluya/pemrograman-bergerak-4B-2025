import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    final String localName = DateTime.now().timeZoneName;
    final String mappedZone = _mapTimeZone(localName);
    try {
      tz.setLocalLocation(tz.getLocation(mappedZone));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  /// Mapping zona waktu berdasarkan nama
  String _mapTimeZone(String name) {
    switch (name.toUpperCase()) {
      case 'WIB':
        return 'Asia/Jakarta';
      case 'WITA':
        return 'Asia/Makassar';
      case 'WIT':
        return 'Asia/Jayapura';
      default:
        return 'Asia/Jakarta';
    }
  }

  /// Jadwalkan notifikasi harian dengan suara kustom
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel_v2',
          'Daily Reminder',
          channelDescription: 'Reminder to exercise every day',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notif'),
        ),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  /// Notifikasi akhir olahraga (dalam beberapa menit dari sekarang)
  Future<void> scheduleExerciseEndNotification({
    required int minutes,
  }) async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));

    await _notificationsPlugin.zonedSchedule(
      999,
      "Hore, Waktu Habis",
      "Waktu olahraga kamu telah selesai! Saatnya istirahat.",
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'exercise_timer_channel_v2',
          'Exercise Timer',
          channelDescription: 'Notification when exercise timer ends',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notif'),
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Hapus semua notifikasi terjadwal
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
