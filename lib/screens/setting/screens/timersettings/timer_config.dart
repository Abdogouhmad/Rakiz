import 'package:flutter/foundation.dart';
import 'package:do_not_disturb/do_not_disturb.dart';

enum TimerMode { focus, shortBreak, longBreak }

class TimerConfig extends ChangeNotifier {
  int focusMinutes = 25;
  int shortBreakMinutes = 5;
  int longBreakMinutes = 15;
  int sessionIntervals = 4;
  bool autoStartNext = false;

  // --------------------
  // DND Settings
  // --------------------
  final _dndPlugin = DoNotDisturbPlugin();
  bool enableDndDuringFocus = false;
  bool _isDndActive = false; // Tracks if we actually turned DND on

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

  /// Sets the DND preference.
  /// If turning ON, it checks for permissions immediately.
  Future<void> setDndEnabled(bool value) async {
    enableDndDuringFocus = value;
    notifyListeners();

    if (value) {
      final granted = await checkNotificationPolicyAccessGranted();
      if (!granted) {
        await openDndSettings();
      }
    }
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

  // --------------------
  // DND Logic
  // --------------------
  Future<bool> checkNotificationPolicyAccessGranted() async {
    try {
      final bool isGranted = await _dndPlugin
          .isNotificationPolicyAccessGranted();
      return isGranted;
    } catch (e) {
      debugPrint('Error checking DND status: $e');
      return false;
    }
  }

  Future<void> openDndSettings() async {
    try {
      await _dndPlugin.openNotificationPolicyAccessSettings();
    } catch (e) {
      debugPrint('Error opening DND settings: $e');
    }
  }

  /// Enables DND if:
  /// 1. The user setting is ON
  /// 2. The current mode is FOCUS
  /// 3. We have permission
  Future<void> startDndSession() async {
    if (!enableDndDuringFocus) return;
    if (currentMode != TimerMode.focus) return;

    try {
      final hasAccess = await checkNotificationPolicyAccessGranted();
      if (hasAccess) {
        // 'priority' allows alarms but blocks most other things.
        await _dndPlugin.setInterruptionFilter(InterruptionFilter.priority);
        _isDndActive = true;
      } else {
        // Optional: Trigger UI to ask for permission here if needed
        debugPrint("DND Permission missing");
      }
    } catch (e) {
      debugPrint("Failed to enable DND: $e");
    }
  }

  /// Restore interruptions (Turn off DND)
  Future<void> stopDndSession() async {
    // Only turn it off if we were the ones who turned it on (or force it if you prefer)
    if (!_isDndActive) return;

    try {
      await _dndPlugin.setInterruptionFilter(InterruptionFilter.all);
      _isDndActive = false;
    } catch (e) {
      debugPrint("Failed to disable DND: $e");
    }
  }
}
