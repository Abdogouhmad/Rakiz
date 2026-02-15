import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:rakiz/screens/setting/screens/timersettings/helper.dart';
import 'package:rakiz/screens/setting/screens/timersettings/timer_config.dart';
import 'package:rakiz/ui/custom_text.dart';

class TimerSettingScreen extends StatelessWidget {
  const TimerSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final config = context.watch<TimerConfig>();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -------------------------------
          // Header
          // -------------------------------
          UiText(
            text: 'Timer',
            type: UiTextType.headlineLarge,
            style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          UiText(
            text: 'Timer Settings',
            type: UiTextType.bodyMedium,
            style: GoogleFonts.roboto(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // -------------------------------
          // Duration Cards
          // -------------------------------
          Row(
            children: [
              Expanded(
                child: HelperUI.timeCardSimple(
                  context: context,
                  title: 'Focus',
                  value: config.focusMinutes,
                  onTap: () => HelperUI.showDurationPickerSimple(
                    context: context,
                    title: 'Focus',
                    initialValue: config.focusMinutes,
                    onChanged: config.setFocus,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HelperUI.timeCardSimple(
                  context: context,
                  title: 'Short break',
                  value: config.shortBreakMinutes,
                  onTap: () => HelperUI.showDurationPickerSimple(
                    context: context,
                    title: 'Short break',
                    initialValue: config.shortBreakMinutes,
                    onChanged: config.setShortBreak,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HelperUI.timeCardSimple(
                  context: context,
                  title: 'Long break',
                  value: config.longBreakMinutes,
                  onTap: () => HelperUI.showDurationPickerSimple(
                    context: context,
                    title: 'Long break',
                    initialValue: config.longBreakMinutes,
                    onChanged: config.setLongBreak,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // -------------------------------
          // Session Length
          // -------------------------------
          HelperUI.sectionCard(
            context: context,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timelapse_rounded,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Session length',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Focus intervals in one session: ${config.sessionIntervals}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 12.0,
                      trackShape: const RoundedRectSliderTrackShape(),
                      activeTrackColor: colors.primary,
                      inactiveTrackColor: colors.surfaceContainerHighest,
                      thumbColor: colors.onPrimaryContainer,

                      // 5. The Tick Marks (dots on the bar)
                      tickMarkShape: const RoundSliderTickMarkShape(
                        tickMarkRadius: 4.0,
                      ),
                      activeTickMarkColor: Colors
                          .transparent, // Hide ticks on the active side for a cleaner look
                      inactiveTickMarkColor: colors.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      valueIndicatorShape:
                          const PaddleSliderValueIndicatorShape(),
                      valueIndicatorColor: colors.onPrimaryContainer,
                      valueIndicatorTextStyle: TextStyle(
                        color: colors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Slider(
                      value: config.sessionIntervals.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: "${config.sessionIntervals.toInt()} Sessions",
                      onChanged: (val) =>
                          config.setSessionIntervals(val.round()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // -------------------------------
          // Toggles
          // -------------------------------
          HelperUI.sectionCard(
            context: context,
            child: Column(
              children: [
                HelperUI.switchTileSimple(
                  context: context,
                  title: 'Auto start next timer',
                  subtitle: 'Start next timer automatically',
                  value: config.autoStartNext,
                  onChanged: config.setAutoStart,
                ),
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: colors.outlineVariant,
                ),
                HelperUI.switchTileSimple(
                  context: context,
                  title: 'Do Not Disturb',
                  subtitle: 'Enable DND during focus',
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
