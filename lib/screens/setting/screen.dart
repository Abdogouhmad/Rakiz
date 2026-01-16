import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/ui/custom_text.dart';
import 'package:rakiz/screens/setting/widget/import.dart';

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
          const _SectionTitle(title: 'Appearance'),
          const SizedBox(height: 8),
          AppearanceCard(isDark: isDark, onThemeChanged: onThemeChanged),
          const SizedBox(height: 32),
          const _SectionTitle(title: 'About'),
          const SizedBox(height: 8),
          const AboutCard(),
          const SizedBox(height: 24),
          const SocialMediaSection(),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                SUB WIDGETS                                 */
/* -------------------------------------------------------------------------- */

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return UiText(
      text: title,
      type: UiTextType.titleLarge,
      style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
    );
  }
}
