import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 5; // Default start
  final int _initialSeconds = 5; // Configurable default

  // Simple getters
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _timer != null;

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

  /// Resets timer back to initial state (e.g. 5 seconds)
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
}
