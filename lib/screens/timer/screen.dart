import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:rakiz/core/context.dart';
import 'package:rakiz/screens/setting/screens/timersettings/timer_config.dart';
import 'package:rakiz/screens/timer/service/alarm.dart';
import 'package:rakiz/screens/timer/service/notification.dart';
import 'package:rakiz/screens/timer/service/timer.dart';
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

  int _totalSeconds = 0;

  int get _secondsLeft => _timerService.remainingSeconds;

  @override
  void initState() {
    super.initState();
    _alarmSubscription = AlarmService.alarmStateStream.listen((isPlaying) {
      if (!isPlaying && mounted) {
        _resetTimer();
      }
    });
  }

  // ---------------------------
  // Lifecycle: Listen for Config Changes
  // ---------------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1. Watch the config for changes
    final config = context.watch<TimerConfig>();

    // 2. Calculate what the duration *should* be based on current settings
    final configDurationInSeconds = config.currentDurationMinutes * 60;

    // 3. If the timer is NOT running and the duration has changed, update immediately.
    //    This ensures settings changes are reflected instantly without a reset,
    //    but prevents resetting a timer that is actively counting down.
    if (!_timerService.isRunning && _totalSeconds != configDurationInSeconds) {
      _applyConfig(config);
    }
  }

  @override
  void dispose() {
    _timerService.stopTimer();
    _alarmSubscription?.cancel();
    super.dispose();
  }

  // ---------------------------
  // Apply settings → timer
  // ---------------------------
  void _applyConfig(TimerConfig config) {
    final seconds = config.currentDurationMinutes * 60;

    _totalSeconds = seconds;
    _timerService
      ..resetTimer()
      ..setDuration(seconds);

    // Force a rebuild just in case this was called outside the build phase
    // (though usually unnecessary inside didChangeDependencies, it's safer for async logic)
    // We check mounted to be safe.
    // Note: We avoid setState during build, but didChangeDependencies runs before build.
  }

  // ---------------------------
  // Start / Stop timer
  // ---------------------------
  Future<void> _toggleTimer() async {
    final config = context.read<TimerConfig>();

    if (_timerService.isRunning) {
      _timerService.stopTimer();
      if (mounted) setState(() {});
      return;
    }

    if (_secondsLeft <= 0) return;

    _timerService.startTimer(
      onTick: (_) {
        if (mounted) setState(() {});
      },
      onFinished: () async {
        await AlarmService.scheduleAlarm(id: 1, delay: Duration.zero);
        await NotificationService.notify(
          id: 1,
          title: 'Time’s up ⏰',
          body: 'Session finished',
        );

        AlarmService.playAlarmSound();
        AlarmService.showOverlayIfAppOpen();

        // ---------------------------
        // Cycle logic
        // ---------------------------
        if (config.currentMode == TimerMode.focus) {
          config.onFocusCompleted();
        } else {
          config.setMode(TimerMode.focus);
        }

        // Apply new cycle config
        _applyConfig(config);

        if (config.autoStartNext) {
          _toggleTimer();
        }

        if (mounted) setState(() {});
      },
    );

    if (mounted) setState(() {});
  }

  // ---------------------------
  // Reset helpers
  // ---------------------------
  Future<void> _onResetPressed() async {
    final config = context.read<TimerConfig>();

    if (AlarmService.isAlarmPlaying) {
      await AlarmService.stopAlarm();
    }

    _applyConfig(config);

    if (mounted) setState(() {});
  }

  void _resetTimer() {
    final config = context.read<TimerConfig>();
    _applyConfig(config);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<TimerConfig>();
    final Color circleColor = context.colorScheme.primary;

    double percent = 0.0;
    if (_totalSeconds > 0) {
      percent = (_secondsLeft / _totalSeconds).clamp(0.0, 1.0);
    }

    String modeLabel = switch (config.currentMode) {
      TimerMode.focus => 'Focus',
      TimerMode.shortBreak => 'Short Break',
      TimerMode.longBreak => 'Long Break',
    };

    return Scaffold(
      appBar: AppBar(
        title: UiText(
          text: modeLabel,
          type: UiTextType.headlineLarge,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double circleSize = (constraints.maxWidth * 0.7).clamp(
              220.0,
              constraints.maxHeight * 0.6,
            );

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TimerCircle(
                    size: circleSize,
                    color: circleColor,
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
                                UiText(
                                  text: 'Timer Running',
                                  type: UiTextType.labelMedium,
                                  style: GoogleFonts.roboto(
                                    color: context.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    child: UiText(
                      text: _timerService.formatTime(_secondsLeft),
                      style: GoogleFonts.robotoSlab(
                        fontWeight: FontWeight.w600,
                        fontSize: circleSize * 0.20,
                        color: _timerService.isRunning
                            ? context.colorScheme.onPrimaryContainer
                            : context.colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---------------------------
                  // Controls
                  // ---------------------------
                  PlayerControlUi(
                    isPlaying: _timerService.isRunning,
                    onPlayPause: _toggleTimer,
                    onReset: _onResetPressed,
                    onNext: () {},
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
