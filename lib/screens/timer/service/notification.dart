import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification service for Android & Linux
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Android channel constants
  static const String _channelId = 'rakiz_timer';
  static const String _channelName = 'Rakiz Timer';
  static const String _channelDesc = 'Pomodoro & timer notifications';

  static bool _initialized = false;

  /// Initialize notifications
  static Future<void> init() async {
    if (_initialized) return;

    const androidSetup = AndroidInitializationSettings('@mipmap/launcher_icon');
    const linuxSetup = LinuxInitializationSettings(defaultActionName: 'open');

    const initSettings = InitializationSettings(
      android: androidSetup,
      linux: linuxSetup,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );

    // ---- Timezone init ----
    tz.initializeTimeZones();

    // Safer local timezone (especially for Morocco)
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Casablanca'));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    // ---- Android specific setup ----
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // Create notification channel (MANDATORY Android 8+)
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.max,
          playSound: true,
        ),
      );

      // Android 13+ permission
      await androidPlugin?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  /// Handle notification tap
  static Future<void> _onNotificationTap(NotificationResponse response) async {
    // Only cleanup logic here (safe for background isolate)
    await cancelAll();
  }

  /// Android notification base config
  static AndroidNotificationDetails _androidDetails({bool isAlarm = false}) {
    return AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      category: isAlarm
          ? AndroidNotificationCategory.alarm
          : AndroidNotificationCategory.reminder,
      fullScreenIntent: isAlarm, // alarm-style popup
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      audioAttributesUsage: isAlarm
          ? AudioAttributesUsage.alarm
          : AudioAttributesUsage.notification,
    );
  }

  /// Show immediate notification (Android + Linux)
  static Future<void> notify({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = NotificationDetails(
      android: _androidDetails(isAlarm: false),
      linux: const LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.critical,
      ),
    );

    await _plugin.show(id, title, body, details);
  }

  /// Schedule notification (ANDROID ONLY)
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    if (!Platform.isAndroid) return;

    // Prevent duplicate alarms
    await cancel(id);

    final scheduleTime = tz.TZDateTime.now(tz.local).add(delay);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      NotificationDetails(android: _androidDetails(isAlarm: true)),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancel one notification
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
