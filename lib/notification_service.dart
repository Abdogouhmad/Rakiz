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

  /// Initialize notifications
  static Future<void> init() async {
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

    /// Android 13+ permission
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    // You can navigate or log here
    // response.payload
  }

  /// Show immediate notification (Android + Linux)
  static Future<void> notify({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
      ),
      linux: const LinuxNotificationDetails(),
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

    // Single AndroidNotificationDetails for this alarm
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // 🔥 wakes device like an alarm
      playSound: true, // plays default device alarm sound
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      audioAttributesUsage: AudioAttributesUsage.alarm
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(delay),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancel one notification
  static Future<void> cancel(int id) => _plugin.cancel(id);

  /// Cancel all notifications
  static Future<void> cancelAll() => _plugin.cancelAll();
}
