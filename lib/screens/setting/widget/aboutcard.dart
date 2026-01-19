import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/screens/setting/service/appinfo.dart';
import 'package:rakiz/ui/custom_text.dart';
import 'package:rakiz/core/context.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(color: context.theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _AboutRow(label: 'App Name', value: Appinfo.appname),
            Divider(height: 24),
            _AboutRow(label: 'Developer', value: 'Abdogouhmad'),
            Divider(height: 24),
            _AboutRow(label: 'Version', value: Appinfo.version),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
          type: UiTextType.bodySmall,
          style: GoogleFonts.roboto(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class AppearanceCard extends StatelessWidget {
  final bool isDark;
  final Function(ThemeMode) onThemeChanged;

  const AppearanceCard({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(color: context.theme.dividerColor),
      ),
      child: ListTile(
        leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 22),
        title: const UiText(text: 'Dark Mode', type: UiTextType.titleSmall),
        subtitle: const UiText(
          text: 'Override system appearance',
          type: UiTextType.labelMedium,
        ),
        trailing: Switch.adaptive(
          value: isDark,
          onChanged: (value) {
            onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
          },
        ),
      ),
    );
  }
}
