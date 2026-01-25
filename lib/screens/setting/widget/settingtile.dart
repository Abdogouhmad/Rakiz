import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/core/context.dart';
import 'package:rakiz/ui/custom_text.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = context.theme;
    final colorScheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeData.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeData.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 24),
        ),
        title: UiText(
          text: title,
          type: UiTextType.titleSmall,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? UiText(
                text: subtitle!,
                type: UiTextType.bodySmall,
                style: GoogleFonts.roboto(color: Colors.grey),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
