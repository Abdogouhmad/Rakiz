import 'dart:io' show Platform;
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rakiz/screens/timer/widgets/alarmoverly.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:rakiz/main.dart';

/// Alarm service using android_alarm_manager_plus for reliable alarms
class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _isAlarmPlaying = false;

  // Port name for communication between isolates
  static const String _portName = 'alarm_port';

  // SharedPreferences keys
  static const String _alarmActiveKey = 'alarm_active';
  static const String _alarmTitleKey = 'alarm_title';
  static const String _alarmBodyKey = 'alarm_body';

  /// Initialize the alarm service
  static Future<void> init() async {
    // Initialize android alarm manager
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }

    // Initialize notifications
    const androidSetup = AndroidInitializationSettings('@mipmap/launcher_icon');
    const linuxSetup = LinuxInitializationSettings(defaultActionName: 'open');
    const initSettings = InitializationSettings(
      android: androidSetup,
      linux: linuxSetup,
    );

    await _notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );

    // Request notification permission for Android 13+
    if (Platform.isAndroid) {
      await _notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    // Register a port to receive messages from the alarm callback
    final ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);

    port.listen((dynamic data) {
      if (data == 'alarm_fired') {
        playAlarmSound();
      }
    });

    tz.initializeTimeZones();
  }

  /// Handle notification tap - stop alarm
  static void _onNotificationTap(NotificationResponse response) async {
    await stopAlarm();
    showOverlayIfAppOpen();
  }

  /// Schedule an alarm (exact time alarm)
  static Future<bool> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    if (!Platform.isAndroid) {
      return false;
    }

    // Save alarm details to SharedPreferences for the callback to access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alarmTitleKey, title);
    await prefs.setString(_alarmBodyKey, body);
    await prefs.setBool(_alarmActiveKey, true);

    // Calculate the alarm time
    final alarmTime = DateTime.now().add(delay);

    // Schedule the alarm using oneShot (fires once at exact time)
    final success = await AndroidAlarmManager.oneShotAt(
      alarmTime,
      id,
      _alarmCallback,
      exact: true,
      wakeup: true, // Wake up device when alarm fires
      rescheduleOnReboot: false,
    );

    return success;
  }

  /// The callback that runs when alarm fires
  /// ⚠️ This MUST be a top-level function or static method
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    // Retrieve alarm details from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString(_alarmTitleKey) ?? 'Timer Complete';
    final body = prefs.getString(_alarmBodyKey) ?? 'Your timer has finished';
    final isActive = prefs.getBool(_alarmActiveKey) ?? false;

    if (!isActive) {
      return;
    }

    // Initialize notification plugin in the isolate
    final FlutterLocalNotificationsPlugin plugin =
        FlutterLocalNotificationsPlugin();

    const androidSetup = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSetup);
    await plugin.initialize(initSettings);

    // Show persistent notification with action buttons
    final androidDetails = AndroidNotificationDetails(
      'rakiz_alarm',
      'Rakiz Alarm',
      channelDescription: 'Timer alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: false, // We'll handle sound separately
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      ongoing: true, // Makes notification persistent
      autoCancel: false, // Doesn't dismiss when tapped
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'stop_alarm',
          'Stop Alarm',
          showsUserInterface: true,
        ),
      ],
    );

    await plugin.show(
      1,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );

    // Send message to main isolate to play sound
    final SendPort? send = IsolateNameServer.lookupPortByName(_portName);
    send?.send('alarm_fired');

    // Play sound directly in isolate as backup
    await _playAlarmInIsolate();
  }

  /// Play alarm sound in the isolate
  static Future<void> _playAlarmInIsolate() async {
    try {
      // Play default system alarm sound
      await FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);

      // Keep the alarm playing for 60 seconds or until stopped
      await Future.delayed(const Duration(seconds: 60));
      await FlutterRingtonePlayer().stop();
    } catch (e) {
      // Silently fail if ringtone player fails in isolate
    }
  }

  /// Play alarm sound in the main app (when app is in foreground)
  static Future<void> playAlarmSound() async {
    if (_isAlarmPlaying) return;

    _isAlarmPlaying = true;

    try {
      // Play default system alarm sound (looping)
      await FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
    } catch (e) {
      debugPrint('$e');
    }
  }

  /// Stop the alarm sound and dismiss notification
  static Future<void> stopAlarm() async {
    // Stop the ringtone player
    try {
      await FlutterRingtonePlayer().stop();
    } catch (e) {
      // Ignore errors
    }

    _isAlarmPlaying = false;

    // Cancel the notification
    await _notificationPlugin.cancel(1);

    // Mark alarm as inactive
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alarmActiveKey, false);
  }

  /// Cancel a specific alarm
  static Future<void> cancel(int id) async {
    if (!Platform.isAndroid) return;

    await AndroidAlarmManager.cancel(id);
    await stopAlarm();

    // Mark alarm as inactive
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alarmActiveKey, false);
  }

  /// Cancel all alarms
  static Future<void> cancelAll() async {
    if (!Platform.isAndroid) return;

    // Note: android_alarm_manager_plus doesn't have cancelAll,
    // so you need to track your alarm IDs and cancel them individually
    await cancel(1); // Cancel your timer alarm
    await stopAlarm();
  }

  /// Check if alarm is currently playing
  static bool get isAlarmPlaying => _isAlarmPlaying;

  /// Trigger alarm immediately (for testing)
  static Future<void> triggerAlarmNow({
    required String title,
    required String body,
  }) async {
    // Save to prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alarmTitleKey, title);
    await prefs.setString(_alarmBodyKey, body);
    await prefs.setBool(_alarmActiveKey, true);

    // Show notification
    final androidDetails = AndroidNotificationDetails(
      'rakiz_alarm',
      'Rakiz Alarm',
      channelDescription: 'Timer alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      ongoing: true,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'stop_alarm',
          'Stop Alarm',
          showsUserInterface: true,
        ),
      ],
    );

    await _notificationPlugin.show(
      1,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );

    // Play alarm
    await playAlarmSound();
  }

  static void showOverlayIfAppOpen() {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, _, _) => const TimerOverlayScreen(),
      ),
    );
  }
}
