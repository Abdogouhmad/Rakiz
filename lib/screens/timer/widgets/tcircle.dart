import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rakiz/core/context.dart';

class TimerCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double percent; // 1. Add percent parameter
  final Widget child;
  final Widget footer;

  const TimerCircle({
    super.key,
    required this.size,
    required this.color,
    required this.percent,
    required this.footer,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      reverse: true,
      radius: size / 2,
      lineWidth: 15.0,
      percent: percent, // 3. Pass the calculated percent here
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: context.colorScheme.surfaceContainerHighest,
      progressColor: color,
      center: child,
      animation: true, // Optional: Smooths the movement
      animateFromLastPercent: true,
      animationDuration: 1000,
      footer: Padding(padding: const EdgeInsets.only(top: 20), child: footer),
    );
  }
}
