import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 1 * 60; // Start at 25 minutes

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
    _remainingSeconds = 1 * 60;
  }

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _timer != null;
}
