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
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _timerService.remainingSeconds;
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _toggleTimer() async {
    if (_timerService.isRunning) {
      // Stop timer and cancel alarm
      _timerService.stopTimer();
      await AlarmService.cancel(1);
    } else {
      // Schedule alarm for when timer finishes
      await AlarmService.scheduleAlarm(
        id: 1,
        title: 'Rakiz Timer Complete! ⏰',
        body: 'Your timer has finished',
        delay: Duration(seconds: _timerService.remainingSeconds),
      );

      // Start the timer
      _timerService.startTimer(
        onTick: (seconds) => setState(() => _secondsLeft = seconds),
        onFinished: () async {
          // Play alarm sound immediately when timer hits 00:00
          await AlarmService.playAlarmSound();
          
          setState(() {});
          
          // Show a dialog to stop the alarm
          if (mounted) {
            _showAlarmDialog();
          }
        },
      );
    }
    setState(() {});
  }

  void _resetTimer() {
    _timerService.resetTimer();
    AlarmService.cancel(1);
    AlarmService.stopAlarm(); // Stop alarm sound if playing
    setState(() => _secondsLeft = _timerService.remainingSeconds);
  }

  // Show dialog to stop alarm
  void _showAlarmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⏰ Timer Complete!'),
        content: const Text('Your timer has finished'),
        actions: [
          TextButton(
            onPressed: () {
              AlarmService.stopAlarm();
              Navigator.of(context).pop();
            },
            child: const Text('Stop Alarm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
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
          onNext: () {
            /* Handle skip logic */
          },
        ),
        
        // Optional: Add a "Stop Alarm" button that's always visible
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
    AlarmService.stopAlarm(); // Stop alarm when screen is disposed
    super.dispose();
  }
}
