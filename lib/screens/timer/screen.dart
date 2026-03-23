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
import 'package:rakiz/screens/timer/break/screen.dart';
import 'package:rakiz/screens/timer/focus/screen.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = context.watch<TimerConfig>();
    final configDurationInSeconds = config.currentDurationMinutes * 60;
    if (!_timerService.isRunning && _totalSeconds != configDurationInSeconds) {
      _applyConfig(config);
    }
  }

  @override
  void dispose() {
    _timerService.stopTimer();
    _alarmSubscription?.cancel();
    context.read<TimerConfig>().stopDndSession();
    super.dispose();
  }

  void _applyConfig(TimerConfig config) {
    final seconds = config.currentDurationMinutes * 60;
    _totalSeconds = seconds;
    _timerService
      ..resetTimer()
      ..setDuration(seconds);
  }

  Future<void> _toggleTimer() async {
    final config = context.read<TimerConfig>();
    if (_timerService.isRunning) {
      _timerService.stopTimer();
      await config.stopDndSession();
      if (mounted) setState(() {});
      return;
    }
    if (_secondsLeft <= 0) return;
    await config.startDndSession();
    _timerService.startTimer(
      onTick: (_) {
        if (mounted) setState(() {});
      },
      onFinished: _handleTimerFinished,
    );
    if (mounted) setState(() {});
  }

  Future<void> _handleTimerFinished() async {
    final config = context.read<TimerConfig>();
    await config.stopDndSession();
    await AlarmService.scheduleAlarm(id: 1, delay: Duration.zero);
    await NotificationService.notify(
      id: 1,
      title: 'Time’s up ⏰',
      body: 'Session finished',
    );
    AlarmService.playAlarmSound();
    AlarmService.showOverlayIfAppOpen();
    _cycleMode(config);
  }

  void _cycleMode(TimerConfig config) {
    if (config.currentMode == TimerMode.focus) {
      config.onFocusCompleted(); // Usually moves to Short Break
    } else {
      config.setMode(TimerMode.focus);
    }
    _applyConfig(config);
    if (config.autoStartNext) {
      _toggleTimer();
    }
    if (mounted) setState(() {});
  }

  Future<void> _onResetPressed() async {
    final config = context.read<TimerConfig>();
    if (AlarmService.isAlarmPlaying) await AlarmService.stopAlarm();
    await config.stopDndSession();
    _applyConfig(config);
    if (mounted) setState(() {});
  }

  void _resetTimer() {
    final config = context.read<TimerConfig>();
    config.stopDndSession();
    _applyConfig(config);
    if (mounted) setState(() {});
  }

  Future<void> _onNextPressed() async {
    final config = context.read<TimerConfig>();
    if (_timerService.isRunning) {
      _timerService.stopTimer();
      await config.stopDndSession();
    }
    if (config.currentMode == TimerMode.focus) {
      config.setMode(TimerMode.shortBreak);
    } else {
      config.setMode(TimerMode.focus);
    }
    _applyConfig(config);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<TimerConfig>();
    final bool isFocus = config.currentMode == TimerMode.focus;

    double percent = 0.0;
    if (_totalSeconds > 0) {
      percent = (_secondsLeft / _totalSeconds).clamp(0.0, 1.0);
    }

    final Widget content = isFocus
        ? const FocusContent()
        : const BreakContent();

    return Scaffold(
      appBar: AppBar(
        title: UiText(
          text: isFocus ? 'Focus Time' : 'Break Time',
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
            // Slightly more conservative size to help smaller screens
            final double circleSize = (constraints.maxWidth * 0.68).clamp(
              200.0,
              constraints.maxHeight * 0.52,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      content,
                      const SizedBox(height: 16),
                      TimerCircle(
                        size: circleSize,
                        color: isFocus
                            ? context.colorScheme.primary
                            : context.colorScheme.tertiary,
                        percent: percent,
                        footer: _timerService.isRunning
                            ? _buildRunningStatus()
                            : const SizedBox.shrink(),
                        child: UiText(
                          text: _timerService.formatTime(_secondsLeft),
                          style: GoogleFonts.robotoSlab(
                            fontWeight: FontWeight.w600,
                            fontSize: circleSize * 0.20,
                            color: _timerService.isRunning
                                ? context.colorScheme.onPrimaryContainer
                                : (isFocus
                                      ? context.colorScheme.primary
                                      : context.colorScheme.tertiary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      PlayerControlUi(
                        isPlaying: _timerService.isRunning,
                        onPlayPause: _toggleTimer,
                        onReset: _onResetPressed,
                        onNext: _onNextPressed,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRunningStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: context.colorScheme.primary),
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
    );
  }
}
