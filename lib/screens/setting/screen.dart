import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/ui/custom_text.dart';

class SettingScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingScreen({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Override system theme'),
              trailing: Switch(
                value: isDark,
                onChanged: (value) {
                  onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _aboutRow('App Name', 'Rakiz'),
                  const SizedBox(height: 12),
                  _aboutRow('Developer', 'Abdogouhmad'),
                  const SizedBox(height: 12),
                  _aboutRow('Version', '1.0.0'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        UiText(
          text: label,
          type: UiTextType.titleSmall,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        ),
        UiText(
          text: value,
          type: UiTextType.labelMedium,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
