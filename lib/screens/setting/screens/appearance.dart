import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/screens/setting/widget/import.dart';
import 'package:rakiz/ui/custom_text.dart';

class AppearanceScreen extends StatefulWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onThemeChanged;

  const AppearanceScreen({
    super.key,
    required this.currentMode,
    required this.onThemeChanged,
  });

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  // We keep a local track of the selection to make the UI snappy
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentMode;
  }

  void _handleThemeChange(ThemeMode mode) {
    setState(() {
      _selectedMode = mode;
    });
    // Call the parent function to update the actual app theme and save to disk
    widget.onThemeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          UiText(
            text: 'Appearance',
            type: UiTextType.headlineLarge,
            style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          UiText(
            text: 'Theme preference',
            type: UiTextType.bodyMedium,
            style: GoogleFonts.roboto(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SelectionTile(
            title: 'System Default',
            isSelected: _selectedMode == ThemeMode.system,
            onTap: () => _handleThemeChange(ThemeMode.system),
          ),
          SelectionTile(
            title: 'Light Mode',
            isSelected: _selectedMode == ThemeMode.light,
            onTap: () => _handleThemeChange(ThemeMode.light),
          ),
          SelectionTile(
            title: 'Dark Mode',
            isSelected: _selectedMode == ThemeMode.dark,
            onTap: () => _handleThemeChange(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}
