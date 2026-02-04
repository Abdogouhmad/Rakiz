import 'package:flutter/material.dart';
import 'package:rakiz/screens/setting/service/appinfo.dart';
import 'package:rakiz/screens/setting/widget/import.dart';
import 'package:rakiz/screens/setting/screens/impo.dart';

class SettingScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentMode;

  const SettingScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentMode,
  });

  // Helper to convert ThemeMode to a user-friendly string
  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: "General"),
        SettingsTile(
          icon: Icons.palette_rounded,
          title: 'Appearance',
          // UI is now interactive by showing the actual current selection here
          subtitle: 'Theme: ${_getThemeName(currentMode)}',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppearanceScreen(
                  currentMode: currentMode,
                  onThemeChanged: onThemeChanged,
                ),
              ),
            );
          },
        ),
        // SettingsTile(
        //   icon: Icons.timer_rounded,
        //   title: 'Timer',
        //   subtitle: 'Timer settings',
        //   onTap: () {
        //     // Update this to point to your actual Timer settings screen when ready
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (_) => AppearanceScreen(
        //           currentMode: currentMode,
        //           onThemeChanged: onThemeChanged,
        //         ),
        //       ),
        //     );
        //   },
        // ),
        const SizedBox(height: 20),
        const SectionHeader(title: "Others"),
        SettingsTile(
          icon: Icons.info_rounded,
          title: 'About',
          subtitle: Appinfo.version,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
          },
        ),
      ],
    );
  }
}
