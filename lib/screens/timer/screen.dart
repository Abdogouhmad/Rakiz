import 'dart:async';
import 'dart:io' show Platform;
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
    
    // Listen to alarm state changes
    // When alarm stops (false), reset the timer
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

  /// Format time from seconds to MM:SS
  String _formatTime(int totalSeconds) {
    return _timerService.formatTime(totalSeconds);
  }

  /// Toggle timer start/stop
  Future<void> _toggleTimer() async {
    if (_timerService.isRunning) {
      // Stop timer and cancel alarm
      _timerService.stopTimer();
      await AlarmService.cancel(1);
      
      if (mounted) setState(() {});
      return;
    }

    // Validate timer has time left
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
      // Schedule alarm
      final scheduled = await AlarmService.scheduleAlarm(
        id: 1,
        title: 'Rakiz Timer Complete! ⏰',
        body: 'Your timer has finished',
        delay: Duration(seconds: _secondsLeft),
      );

      if (!scheduled) {
        throw Exception('Failed to schedule alarm');
      }

      // Start timer
      _timerService.startTimer(
        onTick: (_) {
          if (mounted) setState(() {});
        },
        onFinished: () async {
          // Timer finished naturally
          debugPrint('Timer finished');
          
          // On non-Android platforms, manually trigger notification
          // Android handles this via AlarmManager background callback
          if (!Platform.isAndroid) {
            await AlarmService.showNotification();
            await AlarmService.playAlarmSound();
            AlarmService.showOverlayIfAppOpen();
          } else {
            // On Android, if app is in foreground, we can also show notification
            // The background callback will handle it if app is killed/background
            await AlarmService.playAlarmSound();
            AlarmService.showOverlayIfAppOpen();
          }
        },
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error starting timer: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start timer: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Reset timer to initial state
  void _resetTimer() {
    _timerService.resetTimer();
    if (mounted) setState(() {});
  }

  /// Manual reset button handler
  Future<void> _onResetPressed() async {
    await AlarmService.stopAlarm();
    _resetTimer();
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
                    color: Colors.green.withValues(alpha: 0.2),
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
                  // Add skip functionality if needed
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
