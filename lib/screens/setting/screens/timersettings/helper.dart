import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/ui/custom_text.dart';

class HelperUI {
  /// ---------------------------
  /// Time Card (simple)
  /// ---------------------------
  static Widget timeCardSimple({
    required BuildContext context,
    required String title,
    required int value,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: colors.secondaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UiText(
              text: title,
              type: UiTextType.bodySmall,
              style: GoogleFonts.roboto(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            UiText(
              text: "$value",
              type: UiTextType.headlineMedium,
              style: GoogleFonts.roboto(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------------------
  /// Switch Tile (simple)
  /// ---------------------------
  static Widget switchTileSimple({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      onTap: () => onChanged(!value),
      title: UiText(
        text: title,
        type: UiTextType.titleMedium,
        style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
      ),
      subtitle: UiText(
        text: subtitle,
        type: UiTextType.labelMedium,
        style: GoogleFonts.roboto(color: colors.onSurfaceVariant),
      ),
      trailing: Transform.scale(
        scale: 0.9,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: colors.primary,
          inactiveThumbColor: colors.outline,
          inactiveTrackColor: colors.surfaceContainerHighest,
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.onPrimary;
            }
            return colors.outline;
          }),
        ),
      ),
    );
  }

  /// ---------------------------
  /// Section Card
  /// ---------------------------
  static Widget sectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  /// ---------------------------
  /// Duration Picker
  /// ---------------------------
  static void showDurationPickerSimple({
    required BuildContext context,
    required String title,
    required int initialValue,
    required ValueChanged<int> onChanged,
    int max = 120,
  }) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 16),
              UiText(
                text: "Set $title duration (min)",
                type: UiTextType.titleMedium,
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialValue - 1,
                  ),
                  onSelectedItemChanged: (index) {
                    onChanged(index + 1);
                  },
                  children: List.generate(
                    max,
                    (i) => Center(child: Text("${i + 1}")),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
