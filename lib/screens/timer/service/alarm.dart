import 'dart:async';
import 'dart:io' show Platform;
import 'dart:isolate';
import 'dart:ui';
import 'dart:typed_data';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rakiz/screens/timer/widgets/alarmoverly.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:rakiz/main.dart';

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isAlarmPlaying = false;
  static const String _portName = 'alarm_port';
  static const String _alarmActiveKey = 'alarm_active';
  static const String _alarmTitleKey = 'alarm_title';
  static const String _alarmBodyKey = 'alarm_body';

  // Notification channel constants
  static const String _channelId = 'rakiz_alarm';
  static const String _channelName = 'Rakiz Alarm';
  static const String _channelDesc = 'Timer alarm notifications';

  static final StreamController<bool> _alarmStateController =
      StreamController<bool>.broadcast();
  static Stream<bool> get alarmStateStream => _alarmStateController.stream;

  static Future<void> init() async {
    // Initialize Android Alarm Manager
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }

    // Setup notification initialization settings
    const androidSetup = AndroidInitializationSettings('@mipmap/launcher_icon');
    const linuxSetup = LinuxInitializationSettings(defaultActionName: 'Open');

    const initSettings = InitializationSettings(
      android: androidSetup,
      linux: linuxSetup,
    );

    // Initialize the notification plugin
    await _notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );

    // Android-specific setup
    if (Platform.isAndroid) {
      final androidPlugin = _notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // Request notification permission (Android 13+)
      await androidPlugin?.requestNotificationsPermission();

      // Request exact alarm permission (Android 12+)
      await androidPlugin?.requestExactAlarmsPermission();

      // Create notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      await androidPlugin?.createNotificationChannel(channel);
    }

    // Setup isolate port for communication
    final ReceivePort port = ReceivePort();
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);

    port.listen((dynamic data) {
      if (data == 'alarm_fired') {
        playAlarmSound();
        showOverlayIfAppOpen();
      }
    });

    // Initialize timezone
    tz.initializeTimeZones();
  }

  @pragma('vm:entry-point')
  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap actions
    if (response.actionId == 'stop_alarm') {
      stopAlarm();
    } else {
      stopAlarm();
      showOverlayIfAppOpen();
    }
  }

  /// Show notification manually (for Linux/Windows or foreground notifications)
  static Future<void> showNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString(_alarmTitleKey) ?? 'Timer Complete';
    final body = prefs.getString(_alarmBodyKey) ?? 'Your timer has finished';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      category: AndroidNotificationCategory.alarm,
      ongoing: true,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_alarm',
          'Stop Alarm',
          showsUserInterface: true,
        ),
      ],
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      linux: linuxDetails,
    );

    await _notificationPlugin.show(1, title, body, notificationDetails);
  }

  /// Schedule an alarm
  static Future<bool> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    // Save alarm details to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alarmTitleKey, title);
    await prefs.setString(_alarmBodyKey, body);
    await prefs.setBool(_alarmActiveKey, true);

    // For non-Android platforms, just save preferences
    // The timer will handle triggering the alarm
    if (!Platform.isAndroid) {
      return true;
    }

    // For Android, schedule with AlarmManager
    final alarmTime = DateTime.now().add(delay);

    return await AndroidAlarmManager.oneShotAt(
      alarmTime,
      id,
      _alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: false,
    );
  }

  /// Background alarm callback (Android only)
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_alarmActiveKey) ?? false;

    if (!isActive) return;

    // Initialize notification plugin in isolate
    final FlutterLocalNotificationsPlugin plugin =
        FlutterLocalNotificationsPlugin();

    const androidSetup = AndroidInitializationSettings('@mipmap/launcher_icon');
    await plugin.initialize(
      const InitializationSettings(android: androidSetup),
    );

    // Create notification channel in isolate
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Prepare notification details
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      category: AndroidNotificationCategory.alarm,
      ongoing: true,
      autoCancel: false,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_alarm',
          'Stop Alarm',
          showsUserInterface: true,
        ),
      ],
    );

    // Get alarm details
    final title = prefs.getString(_alarmTitleKey) ?? 'Timer Complete';
    final body = prefs.getString(_alarmBodyKey) ?? 'Your timer has finished';

    // Show notification
    await plugin.show(
      1,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );

    // Send message to main isolate
    final SendPort? send = IsolateNameServer.lookupPortByName(_portName);
    send?.send('alarm_fired');

    // Play alarm sound in isolate
    await _playAlarmInIsolate();
  }

  /// Play alarm sound in isolate (background)
  static Future<void> _playAlarmInIsolate() async {
    try {
      await FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
      await Future.delayed(const Duration(seconds: 60));
      await FlutterRingtonePlayer().stop();
    } catch (e) {
      debugPrint('Error playing alarm in isolate: $e');
    }
  }

  /// Play alarm sound in foreground
  static Future<void> playAlarmSound() async {
    if (_isAlarmPlaying) return;

    _isAlarmPlaying = true;
    _alarmStateController.add(true);

    try {
      await FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
    } catch (e) {
      debugPrint('Error playing alarm sound: $e');
    }
  }

  /// Stop the alarm
  static Future<void> stopAlarm() async {
    try {
      await FlutterRingtonePlayer().stop();
    } catch (e) {
      debugPrint('Error stopping alarm: $e');
    }

    _isAlarmPlaying = false;
    _alarmStateController.add(false);

    // Cancel notification
    await _notificationPlugin.cancel(1);

    // Clear alarm active flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alarmActiveKey, false);
  }

  /// Cancel scheduled alarm
  static Future<void> cancel(int id) async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(id);
    }
    await stopAlarm();
  }

  /// Check if alarm is currently playing
  static bool get isAlarmPlaying => _isAlarmPlaying;

  /// Show overlay screen if app is open
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

  /// Test notification (for debugging)
  static Future<void> testNotification() async {
    await showNotification();
    await playAlarmSound();
  }

  /// Dispose resources
  static void dispose() {
    _alarmStateController.close();
  }
}
