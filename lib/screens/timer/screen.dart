import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/screens/timer/widgets/player.dart';
import 'package:rakiz/ui/custom_text.dart';
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

  void _toggleTimer() {
    if (_timerService.isRunning) {
      _timerService.stopTimer();
    } else {
      _timerService.startTimer(
        onTick: (seconds) => setState(() => _secondsLeft = seconds),
        onFinished: () => setState(() {}),
      );
    }
    setState(() {}); // Rebuild to update button icon
  }

  void _resetTimer() {
    _timerService.resetTimer();
    setState(() => _secondsLeft = _timerService.remainingSeconds);
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
      ],
    );
  }

  @override
  void dispose() {
    _timerService.stopTimer();
    super.dispose();
  }
}
