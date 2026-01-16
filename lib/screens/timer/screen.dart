import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming these exist in your project structure
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
  // Assuming TimerService handles the visual countdown logic (ticks)
  final TimerService _timerService = TimerService();
  StreamSubscription<AlarmSettings>? _alarmSubscription;

  int get _secondsLeft => _timerService.remainingSeconds;

  @override
  void initState() {
    super.initState();

    // Listen to the Alarm package ring stream.
    // This event fires when the alarm actually starts ringing.
    _alarmSubscription = AlarmService.ringStream.listen((alarmSettings) {
      if (alarmSettings.id == AlarmService.timerAlarmId) {
        // You might want to show a dialog here or change UI state
        debugPrint("Alarm is ringing!");
        // We don't reset the timer here immediately, usually we wait
        // for the user to click "Stop"
      }
    });
  }

  @override
  void dispose() {
    _timerService.stopTimer();
    _alarmSubscription?.cancel();
    super.dispose();
  }

  /// Format time from seconds to MM:SS
  String _formatTime(int totalSeconds) {
    // Fallback if TimerService doesn't have this method yet
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Toggle timer start/stop
  Future<void> _toggleTimer() async {
    if (_timerService.isRunning) {
      // 1. User pressed Pause/Stop
      _timerService.stopTimer();
      await AlarmService.stopAlarm();

      if (mounted) setState(() {});
      return;
    }

    // 2. Validate timer has time left
    if (_secondsLeft <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please set a timer duration first'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      // 3. Schedule the Alarm (Background)
      // We rely on the Alarm package to handle audio/notifications at the end
      final success = await AlarmService.scheduleAlarm(
        title: 'Rakiz Timer',
        body: 'Time is up!',
        delay: Duration(seconds: _secondsLeft),
      );

      if (!success) {
        throw Exception('Failed to schedule system alarm');
      }

      // 4. Start the Visual Timer (Foreground)
      _timerService.startTimer(
        onTick: (_) {
          if (mounted) setState(() {});
        },
        onFinished: () {
          // Visual timer finished.
          // We DO NOT play sound here manually.
          // The AlarmService (via alarm package) handles the sound/notification automatically
          // based on the schedule we set in step 3.
          debugPrint('Visual timer finished');
          if (mounted) setState(() {});
        },
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error starting timer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Reset timer and stop any ringing alarms
  Future<void> _onResetPressed() async {
    await AlarmService.stopAlarm(); // Stop audio if ringing
    _timerService.resetTimer(); // Reset visual numbers
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
              // Timer display
              UiText(
                text: _formatTime(_secondsLeft),
                type: UiTextType.displayLarge,
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoSlab(
                  fontWeight: FontWeight.w600,
                  fontSize: 72,
                ),
              ),

              const SizedBox(height: 20),

              // Status indicator
              if (_timerService.isRunning)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Timer Running',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // Player controls
              PlayerControlUi(
                isPlaying: _timerService.isRunning,
                onPlayPause: _toggleTimer,
                onReset: _onResetPressed,
                onNext: () {
                  // Optional: Add logic to add +1 minute or similar
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
