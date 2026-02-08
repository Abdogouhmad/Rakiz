import 'package:flutter/foundation.dart';

enum TimerMode { focus, shortBreak, longBreak }

class TimerConfig extends ChangeNotifier {
  int focusMinutes = 25;
  int shortBreakMinutes = 5;
  int longBreakMinutes = 15;
  int sessionIntervals = 4;
  bool autoStartNext = false;

  TimerMode currentMode = TimerMode.focus;
  int completedFocusSessions = 0;

  // --------------------
  // Setters
  // --------------------
  void setFocus(int value) {
    focusMinutes = value;
    notifyListeners();
  }

  void setShortBreak(int value) {
    shortBreakMinutes = value;
    notifyListeners();
  }

  void setLongBreak(int value) {
    longBreakMinutes = value;
    notifyListeners();
  }

  void setSessionIntervals(int value) {
    sessionIntervals = value;
    notifyListeners();
  }

  void setAutoStart(bool value) {
    autoStartNext = value;
    notifyListeners();
  }

  // --------------------
  // Logic
  // --------------------
  int get currentDurationMinutes {
    switch (currentMode) {
      case TimerMode.focus:
        return focusMinutes;
      case TimerMode.shortBreak:
        return shortBreakMinutes;
      case TimerMode.longBreak:
        return longBreakMinutes;
    }
  }

  void setMode(TimerMode mode) {
    currentMode = mode;
    notifyListeners();
  }

  void onFocusCompleted() {
    completedFocusSessions++;

    if (completedFocusSessions % sessionIntervals == 0) {
      currentMode = TimerMode.longBreak;
    } else {
      currentMode = TimerMode.shortBreak;
    }

    notifyListeners();
  }

  void resetCycle() {
    completedFocusSessions = 0;
    currentMode = TimerMode.focus;
    notifyListeners();
  }
}
