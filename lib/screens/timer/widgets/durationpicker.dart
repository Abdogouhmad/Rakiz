import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/ui/custom_text.dart';

class DurationPickerDialog extends StatefulWidget {
  final int initialSeconds;

  const DurationPickerDialog({super.key, this.initialSeconds = 0});

  @override
  State<DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;

  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Parse initial duration
    _selectedHours = widget.initialSeconds ~/ 3600;
    _selectedMinutes = (widget.initialSeconds % 3600) ~/ 60;
    _selectedSeconds = widget.initialSeconds % 60;

    _hoursController = FixedExtentScrollController(initialItem: _selectedHours);
    _minutesController = FixedExtentScrollController(
      initialItem: _selectedMinutes,
    );
    _secondsController = FixedExtentScrollController(
      initialItem: _selectedSeconds,
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  int get _totalSeconds =>
      (_selectedHours * 3600) + (_selectedMinutes * 60) + _selectedSeconds;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiText(
              text: 'Set Timer Duration',
              type: UiTextType.titleLarge,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Duration Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours
                _buildTimeColumn(
                  controller: _hoursController,
                  maxValue: 23,
                  label: 'h',
                  onChanged: (value) {
                    setState(() => _selectedHours = value);
                  },
                ),

                const SizedBox(width: 16),

                // Minutes
                _buildTimeColumn(
                  controller: _minutesController,
                  maxValue: 59,
                  label: 'min',
                  onChanged: (value) {
                    setState(() => _selectedMinutes = value);
                  },
                ),

                const SizedBox(width: 16),

                // Seconds
                _buildTimeColumn(
                  controller: _secondsController,
                  maxValue: 59,
                  label: 'sec',
                  onChanged: (value) {
                    setState(() => _selectedSeconds = value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Presets
            Wrap(
              spacing: 8,
              runSpacing: 5,
              alignment: WrapAlignment.center,
              children: [
                _buildPresetChip('5 sec', 5),
                _buildPresetChip('1 min', 60),
                _buildPresetChip('5 min', 5 * 60),
                _buildPresetChip('10 min', 10 * 60),
                _buildPresetChip('30 min', 30 * 60),
                _buildPresetChip('1 hour', 60 * 60),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _totalSeconds > 0
                      ? () => Navigator.of(context).pop(_totalSeconds)
                      : null,
                  child: const Text('Set Timer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn({
    required FixedExtentScrollController controller,
    required int maxValue,
    required String label,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          width: 70,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 50,
            perspective: 0.003,
            diameterRatio: 1.3,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: maxValue + 1,
              builder: (context, index) {
                final isSelected = index == controller.selectedItem;
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: isSelected ? 32 : 24,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, int seconds) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.transparent,
      labelStyle: GoogleFonts.roboto(fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: BorderSide(
          width: 0.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onPressed: () {
        setState(() {
          _selectedHours = seconds ~/ 3600;
          _selectedMinutes = (seconds % 3600) ~/ 60;
          _selectedSeconds = seconds % 60;

          _hoursController.jumpToItem(_selectedHours);
          _minutesController.jumpToItem(_selectedMinutes);
          _secondsController.jumpToItem(_selectedSeconds);
        });
      },
    );
  }
}

// Helper function to show the picker
Future<int?> showDurationPicker({
  required BuildContext context,
  int initialSeconds = 0,
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => DurationPickerDialog(initialSeconds: initialSeconds),
  );
}
