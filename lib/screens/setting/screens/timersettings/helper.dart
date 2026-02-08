import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: colors.secondaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$value",
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: CupertinoSwitch(
          value: value,
          activeTrackColor: colors.primary,
          onChanged: onChanged,
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
        borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                "Set $title duration (min)",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
