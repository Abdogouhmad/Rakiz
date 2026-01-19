import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/core/context.dart';
import 'package:rakiz/screens/timer/service/alarm.dart';
import 'package:rakiz/screens/timer/service/timer.dart';
import 'package:rakiz/screens/timer/widgets/durationpicker.dart';
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
    _timerService.setDuration(5 * 60);

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
      _timerService.setDuration(selectedSeconds);
      if (mounted) setState(() {});
    }
  }

  /// Start / stop timer
  Future<void> _toggleTimer() async {
    if (_timerService.isRunning) {
      // Just stop the timer, don't cancel alarm (it's not scheduled yet!)
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
        // Schedule the alarm when timer finishes
        await AlarmService.scheduleAlarm(
          id: 1,
          delay: Duration.zero, // Fire immediately
        );
        AlarmService.playAlarmSound();
        AlarmService.showOverlayIfAppOpen();
        if (mounted) setState(() {});
      },
    );

    if (mounted) setState(() {});
  }

  /// Reset timer and stop alarm if playing
  Future<void> _onResetPressed() async {
    // Only stop alarm if it's actually playing
    if (AlarmService.isAlarmPlaying) {
      await AlarmService.stopAlarm();
    }

    // If timer is running, cancel the scheduled alarm
    if (_timerService.isRunning) {
      await AlarmService.cancel(1);
    }

    _timerService.resetTimer();
    if (mounted) setState(() {});
  }

  /// reset timer
  void _resetTimer() {
    _timerService.resetTimer();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Make timer text tappable to change duration
              GestureDetector(
                onTap: _timerService.isRunning ? null : _showTimePicker,
                // TODO: use circle around the timer formyted
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

              const SizedBox(height: 20),

              if (_timerService.isRunning)
                Container(
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
              else
                TextButton.icon(
                  onPressed: _showTimePicker,
                  icon: const Icon(Icons.edit),
                  label: const Text('Set Duration'),
                ),

              const SizedBox(height: 40),

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
