import 'dart:async';
import 'dart:io' show Platform;
import 'dart:isolate';
import 'dart:ui';
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

  static final StreamController<bool> _alarmStateController =
      StreamController<bool>.broadcast();
  static Stream<bool> get alarmStateStream => _alarmStateController.stream;

  static Future<void> init() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }

    const androidSetup = AndroidInitializationSettings('@mipmap/launcher_icon');
    // Ensure defaultActionName is set for Linux
    const linuxSetup = LinuxInitializationSettings(defaultActionName: 'Open');

    const initSettings = InitializationSettings(
      android: androidSetup,
      linux: linuxSetup,
    );

    await _notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      await _notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    final ReceivePort port = ReceivePort();
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);

    port.listen((dynamic data) {
      if (data == 'alarm_fired') {
        playAlarmSound();
        showOverlayIfAppOpen();
      }
    });

    tz.initializeTimeZones();
  }

  @pragma('vm:entry-point')
  static void _onNotificationTap(NotificationResponse response) {
    stopAlarm();
    showOverlayIfAppOpen();
  }

  /// Manually show notification (Required for Linux/Windows where AlarmManager doesn't exist)
  static Future<void> showNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString(_alarmTitleKey) ?? 'Timer Complete';
    final body = prefs.getString(_alarmBodyKey) ?? 'Your timer has finished';

    const androidDetails = AndroidNotificationDetails(
      'rakiz_alarm',
      'Rakiz Alarm',
      channelDescription: 'Timer alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: false,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      ongoing: true,
      autoCancel: false,
    );

    // Linux specific details
    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      linux: linuxDetails,
    );

    await _notificationPlugin.show(1, title, body, notificationDetails);
  }

  static Future<bool> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    // Save prefs regardless of platform so manual triggers work
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alarmTitleKey, title);
    await prefs.setString(_alarmBodyKey, body);
    await prefs.setBool(_alarmActiveKey, true);

    if (!Platform.isAndroid) {
      // On Linux/iOS, we rely on the TimerService in the main app to trigger the end state
      return true;
    }

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

  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_alarmActiveKey) ?? false;

    if (!isActive) return;

    // ... (Existing Android Background Logic) ...
    final FlutterLocalNotificationsPlugin plugin =
        FlutterLocalNotificationsPlugin();
    const androidSetup = AndroidInitializationSettings('@mipmap/launcher_icon');
    await plugin.initialize(
      const InitializationSettings(android: androidSetup),
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'rakiz_alarm',
      'Rakiz Alarm',
      description: 'Timer alarm notifications',
      importance: Importance.max,
      playSound: false,
      enableVibration: true,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: false,
      enableVibration: true,
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

    // We reuse the logic, but usually this callback only runs on Android
    final title = prefs.getString(_alarmTitleKey) ?? 'Timer Complete';
    final body = prefs.getString(_alarmBodyKey) ?? 'Your timer has finished';

    await plugin.show(
      1,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );

    final SendPort? send = IsolateNameServer.lookupPortByName(_portName);
    send?.send('alarm_fired');

    await _playAlarmInIsolate();
  }

  static Future<void> _playAlarmInIsolate() async {
    try {
      await FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
      await Future.delayed(const Duration(seconds: 60));
      await FlutterRingtonePlayer().stop();
    } catch (_) {}
  }

  static Future<void> playAlarmSound() async {
    if (_isAlarmPlaying) return;
    _isAlarmPlaying = true;
    _alarmStateController.add(true);

    try {
      await FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<void> stopAlarm() async {
    try {
      await FlutterRingtonePlayer().stop();
    } catch (_) {}

    _isAlarmPlaying = false;
    _alarmStateController.add(false);

    await _notificationPlugin.cancel(1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alarmActiveKey, false);
  }

  static Future<void> cancel(int id) async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(id);
    }
    await stopAlarm();
  }

  static bool get isAlarmPlaying => _isAlarmPlaying;

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
