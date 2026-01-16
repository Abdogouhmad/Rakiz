import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmService {
  // Use a constant ID for the timer alarm to easily cancel/update it
  static const int timerAlarmId = 42;

  /// Schedule an alarm for [delay] duration from now.
  static Future<bool> scheduleAlarm({
    required String title,
    required String body,
    required Duration delay,
  }) async {
    // 1. Check permissions first
    await checkAndroidScheduleExactAlarmPermission();

    // 2. Define the alarm settings
    final alarmSettings = AlarmSettings(
      id: timerAlarmId,
      dateTime: DateTime.now().add(delay),
      assetAudioPath:
          'assets/alarm.mp3', // Make sure this file exists in pubspec
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 2),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'Stop',
        icon: 'notification_icon', // Ensure this drawable exists in Android/iOS
      ),
      // Android specific: ensures alarm rings even if app is killed
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
    );

    // 3. Set the alarm
    return await Alarm.set(alarmSettings: alarmSettings);
  }

  /// Stop the alarm if it is ringing or cancel it if scheduled.
  static Future<bool> stopAlarm() async {
    return await Alarm.stop(timerAlarmId);
  }

  /// Check if the specific timer alarm is currently active
  static Future<bool> isAlarmSet() async {
    return Alarm.getAlarm(timerAlarmId) != null;
  }

  /// Expose the stream to listen when the alarm starts ringing
  static Stream<AlarmSettings> get ringStream => Alarm.ringStream.stream;

  /// Android 12+ requires explicit permission for exact alarms
  static Future<void> checkAndroidScheduleExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }
  }
}
