import 'package:flutter/material.dart';
import 'package:rakiz/screens/setting/service/appinfo.dart';
import 'package:rakiz/screens/setting/widget/import.dart';
import 'package:rakiz/screens/setting/screens/impo.dart';

class SettingScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingScreen({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(title: "General",),
        SettingsTile(
          icon: Icons.palette_rounded,
          title: 'Appearance',
          subtitle: 'Theme & colors',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppearanceScreen(
                  currentMode: Theme.of(context).brightness == Brightness.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  onThemeChanged: onThemeChanged,
                ),
              ),
            );
          },
        ),
        SettingsTile(
          icon: Icons.timer_rounded,
          title: 'Timer',
          subtitle: 'timer settings',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppearanceScreen(
                  currentMode: Theme.of(context).brightness == Brightness.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  onThemeChanged: onThemeChanged,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),
        SectionHeader(title: "Others",),
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
