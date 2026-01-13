import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rakiz/screens/timer/service/alarm.dart';

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 5;
  final int _initialSeconds = 5;

  void startTimer({
    required Function(int) onTick,
    required VoidCallback onFinished,
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        onTick(_remainingSeconds);
      } else {
        stopTimer();
        onFinished();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void resetTimer() {
    stopTimer();
    _remainingSeconds = _initialSeconds;
  }

  String formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _timer != null;
}

/// Helper function to handle the logic between TimerService and AlarmService
Future<void> theTimerToggler(
  TimerService timerService,
  VoidCallback onStateChange,
) async {
  if (timerService.isRunning) {
    // Stop: Cancel Timer and Android Alarm
    timerService.stopTimer();
    await AlarmService.cancel(1);
  } else {
    // Start: Schedule Alarm first, then start local ticker
    await AlarmService.scheduleAlarm(
      id: 1,
      title: 'Rakiz Timer Complete! ⏰',
      body: 'Your timer has finished',
      delay: Duration(seconds: timerService.remainingSeconds),
    );

    timerService.startTimer(
      onTick: (_) => onStateChange(),
      onFinished: () => onStateChange(),
    );
  }

  onStateChange();
}
