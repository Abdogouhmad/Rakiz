import 'dart:async';
import 'dart:io' show Platform;
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:rakiz/main.dart';
import 'package:rakiz/screens/timer/service/notification.dart';
import 'package:rakiz/screens/timer/widgets/alarmoverly.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmService {
  static const String _portName = 'alarm_port';
  static const String _alarmActiveKey = 'alarm_active';

  static bool _isAlarmPlaying = false;

  static final StreamController<bool> _alarmStateController =
      StreamController<bool>.broadcast();

  static Stream<bool> get alarmStateStream => _alarmStateController.stream;

  /// Initialize alarm service
  static Future<void> init() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }

    final ReceivePort port = ReceivePort();
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);

    port.listen((message) {
      if (message == 'alarm_fired') {
        playAlarmSound();
        showOverlayIfAppOpen();
      }
    });
  }

  /// Schedule alarm
  static Future<bool> scheduleAlarm({
    required int id,
    required Duration delay,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alarmActiveKey, true);

    if (!Platform.isAndroid) return true;

    return AndroidAlarmManager.oneShotAt(
      DateTime.now().add(delay),
      id,
      _alarmCallback,
      exact: true,
      wakeup: true,
    );
  }

  /// Android background callback
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    WidgetsFlutterBinding.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_alarmActiveKey) ?? false;
    if (!isActive) return;

    // Notify foreground isolate
    final SendPort? send = IsolateNameServer.lookupPortByName(_portName);
    send?.send('alarm_fired');

    // 🔔 SHOW NOTIFICATION HERE (SYNCED)
    await NotificationService.notify(
      id: 1,
      title: 'Time’s up ⏰',
      body: 'Your focus session has finished',
    );

    // 🔊 Play alarm sound
    await _playAlarmInIsolate();
  }

  /// Background alarm sound
  static Future<void> _playAlarmInIsolate() async {
    try {
      await FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);

      await Future.delayed(const Duration(seconds: 60));
      await FlutterRingtonePlayer().stop();
    } catch (e) {
      debugPrint('Alarm isolate error: $e');
    }
  }

  /// Foreground alarm sound
  static Future<void> playAlarmSound() async {
    if (_isAlarmPlaying) return;

    _isAlarmPlaying = true;
    _alarmStateController.add(true);

    try {
      await FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
    } catch (e) {
      debugPrint('Alarm play error: $e');
    }
  }

  /// Stop alarm (called by overlay)
  static Future<void> stopAlarm() async {
    try {
      await FlutterRingtonePlayer().stop();
    } catch (e) {
      debugPrint('Alarm stop error: $e');
    }

    _isAlarmPlaying = false;
    _alarmStateController.add(false);

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

  static bool get isAlarmPlaying => _isAlarmPlaying;

  /// Show overlay when app is alive
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

  static void dispose() {
    _alarmStateController.close();
  }
}
