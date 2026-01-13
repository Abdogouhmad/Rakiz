import 'package:flutter/material.dart';
import 'package:rakiz/screens/timer/service/alarm.dart';

class TimerOverlayScreen extends StatelessWidget {
  const TimerOverlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        await AlarmService.stopAlarm();
        navigator.pop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.alarm, size: 72, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Stop Alarm?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Current timer is complete.\nTap anywhere to stop the alarm.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
