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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          UiText(
            text: 'Appearance',
            type: UiTextType.titleLarge,
            style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          UiText(
            text: 'Theme preference',
            type: UiTextType.bodySmall,
            style: GoogleFonts.roboto(color: Colors.grey),
          ),
          const SizedBox(height: 8),
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
