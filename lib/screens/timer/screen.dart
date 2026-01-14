import 'dart:async';
import 'dart:io' show Platform; // Import Platform
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/screens/timer/service/alarm.dart';
import 'package:rakiz/screens/timer/service/timer.dart';
import 'package:rakiz/screens/timer/widgets/player.dart';
import 'package:rakiz/ui/custom_text.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TimerService _timerService = TimerService();
  StreamSubscription<bool>? _alarmSubscription;

  int get _secondsLeft => _timerService.remainingSeconds;

  @override
  void initState() {
    super.initState();
    // Listen to AlarmService. When alarm stops (false), reset the timer.
    _alarmSubscription = AlarmService.alarmStateStream.listen((isPlaying) {
      if (!isPlaying) {
        _resetTimer();
      }
    });
  }

  @override
  void dispose() {
    _timerService.stopTimer();
    _alarmSubscription?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    return _timerService.formatTime(totalSeconds);
  }

  Future<void> _toggleTimer() async {
    if (_timerService.isRunning) {
      // ⏹ Stop timer + alarm manually
      _timerService.stopTimer();
      await AlarmService.cancel(1);
    } else {
      // ⏰ Schedule alarm
      // On Android, this sets the AlarmManager. On Linux, it just saves prefs.
      await AlarmService.scheduleAlarm(
        id: 1,
        title: 'Rakiz Timer Complete! ⏰',
        body: 'Your timer has finished',
        delay: Duration(seconds: _secondsLeft),
      );

      // ▶ Start timer
      _timerService.startTimer(
        onTick: (_) => setState(() {}),
        onFinished: () async {
          // Timer naturally finished

          // Fix for Linux: Trigger notification manually if not on Android
          // (Android handles it via AlarmManager background callback usually,
          // but strictly speaking, if the app is open, doing it here is also fine
          // but we avoid duplicates by restricting to !Android)
          if (!Platform.isAndroid) {
            await AlarmService.showNotification();
          }

          await AlarmService.playAlarmSound();
          AlarmService.showOverlayIfAppOpen();
        },
      );
    }

    setState(() {});
  }

  void _resetTimer() {
    // This is called automatically via the stream when alarm stops
    _timerService.resetTimer();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UiText(
          text: _formatTime(_secondsLeft),
          type: UiTextType.displayLarge,
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 40),

        // Clean player UI, no red buttons
        PlayerControlUi(
          isPlaying: _timerService.isRunning,
          onPlayPause: _toggleTimer,
          onReset: () {
            // Manual reset button logic
            AlarmService.stopAlarm();
            _resetTimer();
          },
          onNext: () {},
        ),
      ],
    );
  }
}
