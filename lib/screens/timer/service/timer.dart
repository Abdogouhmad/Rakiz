import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _initialSeconds = 0;

  // Simple getters
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _timer != null;

  /// Set the timer duration
  void setDuration(int seconds) {
    if (isRunning) return; // Don't allow changing duration while running
    _initialSeconds = seconds;
    _remainingSeconds = seconds;
  }

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

  /// Resets timer back to initial state
  void resetTimer() {
    stopTimer();
    _remainingSeconds = _initialSeconds;
  }

  String formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
