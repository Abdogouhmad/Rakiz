import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/screens/timer/widgets/player.dart';
import 'package:rakiz/ui/custom_text.dart';
import 'package:rakiz/alarm.dart';
import 'service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TimerService _timerService = TimerService();

  int get _secondsLeft => _timerService.remainingSeconds;

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleTimer() async {
    if (_timerService.isRunning) {
      // ⏹ Stop timer + alarm
      _timerService.stopTimer();
      await AlarmService.cancel(1);
    } else {
      // ⏰ Schedule alarm
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
          await AlarmService.playAlarmSound();
          AlarmService.showOverlayIfAppOpen();
        },
      );
    }

    setState(() {});
  }

  void _resetTimer() {
    _timerService.resetTimer();
    AlarmService.stopAlarm();
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
        PlayerControlUi(
          isPlaying: _timerService.isRunning,
          onPlayPause: _toggleTimer,
          onReset: _resetTimer,
          onNext: () {},
        ),
        if (AlarmService.isAlarmPlaying)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton.icon(
              onPressed: () async {
                await AlarmService.stopAlarm();
                setState(() {});
              },
              icon: const Icon(Icons.alarm_off),
              label: const Text('Stop Alarm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _timerService.stopTimer();
    super.dispose();
  }
}
