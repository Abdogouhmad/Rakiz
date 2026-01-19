import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/core/context.dart';
import 'package:rakiz/screens/timer/service/alarm.dart';
import 'package:rakiz/screens/timer/service/timer.dart';
import 'package:rakiz/screens/timer/widgets/durationpicker.dart';
import 'package:rakiz/screens/timer/widgets/player.dart';
import 'package:rakiz/screens/timer/widgets/tcircle.dart';
import 'package:rakiz/ui/custom_text.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TimerService _timerService = TimerService();
  StreamSubscription<bool>? _alarmSubscription;

  // Track total duration to calculate percentage
  int _totalSeconds = 5 * 60;

  int get _secondsLeft => _timerService.remainingSeconds;

  @override
  void initState() {
    super.initState();
    // Initialize service with default time
    _timerService.setDuration(_totalSeconds);

    _alarmSubscription = AlarmService.alarmStateStream.listen((isPlaying) {
      if (!isPlaying && mounted) {
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

  /// method to pick time duration
  Future<void> _showTimePicker() async {
    if (_timerService.isRunning) return;

    final int? selectedSeconds = await showDurationPicker(
      context: context,
      initialSeconds: _secondsLeft,
    );

    if (selectedSeconds != null && selectedSeconds > 0) {
      setState(() {
        _totalSeconds = selectedSeconds; // Update total for percentage calc
        _timerService.setDuration(selectedSeconds);
      });
    }
  }

  /// Start / stop timer
  Future<void> _toggleTimer() async {
    if (_timerService.isRunning) {
      _timerService.stopTimer();
      if (mounted) setState(() {});
      return;
    }

    if (_secondsLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a timer duration first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _timerService.startTimer(
      onTick: (_) {
        if (mounted) setState(() {});
      },
      onFinished: () async {
        await AlarmService.scheduleAlarm(id: 1, delay: Duration.zero);
        AlarmService.playAlarmSound();
        AlarmService.showOverlayIfAppOpen();
        if (mounted) setState(() {});
      },
    );

    if (mounted) setState(() {});
  }

  /// Reset timer and stop alarm if playing
  Future<void> _onResetPressed() async {
    if (AlarmService.isAlarmPlaying) {
      await AlarmService.stopAlarm();
    }

    if (_timerService.isRunning) {
      await AlarmService.cancel(1);
    }

    _timerService.resetTimer();
    // Also reset the service duration back to the last selected total
    _timerService.setDuration(_totalSeconds);

    if (mounted) setState(() {});
  }

  /// reset timer helper
  void _resetTimer() {
    _timerService.resetTimer();
    _timerService.setDuration(_totalSeconds);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double size = context.screenWidth * 0.7;
    final Color cireclColor = context.colorScheme.primary;

    // Calculate percent: 1.0 (full) -> 0.0 (empty)
    double percent = 0.0;
    if (_totalSeconds > 0) {
      percent = (_secondsLeft / _totalSeconds).clamp(0.0, 1.0);
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _timerService.isRunning ? null : _showTimePicker,
                child: TimerCircle(
                  size: size,
                  color: cireclColor,
                  percent: percent,
                  footer: _timerService.isRunning
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.surfaceBright,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: context.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Timer Running',
                                style: TextStyle(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : TextButton.icon(
                          onPressed: _showTimePicker,
                          icon: const Icon(Icons.edit),
                          label: const Text('Set Duration'),
                        ),
                  child: UiText(
                    text: _timerService.formatTime(_secondsLeft),
                    type: UiTextType.displayLarge,
                    style: GoogleFonts.robotoSlab(
                      fontWeight: FontWeight.w600,
                      fontSize: 72,
                      color: _timerService.isRunning
                          ? context.colorScheme.onPrimaryContainer
                          : context.colorScheme.primary,
                    ),
                  ),
                ),
              ),

              // Timer Display with Indicator
              const SizedBox(height: 40),

              // Player Controls
              PlayerControlUi(
                isPlaying: _timerService.isRunning,
                onPlayPause: _toggleTimer,
                onReset: _onResetPressed,
                onNext: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
