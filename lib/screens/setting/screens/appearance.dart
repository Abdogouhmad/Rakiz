import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/screens/setting/widget/import.dart';
import 'package:rakiz/ui/custom_text.dart';

class AppearanceScreen extends StatelessWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onThemeChanged;

  const AppearanceScreen({
    super.key,
    required this.currentMode,
    required this.onThemeChanged,
  });
  // Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             UiText(
  //               text: 'Appearance',
  //               type: UiTextType.titleLarge,
  //               style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
  //             ),
  //             const SizedBox(height: 2),
  //             UiText(
  //               text: 'Theme preference',
  //               type: UiTextType.bodySmall,
  //               style: GoogleFonts.roboto(color: Colors.grey),
  //             ),
  //           ],
  //         )
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
            isSelected: currentMode == ThemeMode.system,
            onTap: () => onThemeChanged(ThemeMode.system),
          ),
          SelectionTile(
            title: 'Light Mode',
            isSelected: currentMode == ThemeMode.light,
            onTap: () => onThemeChanged(ThemeMode.light),
          ),
          SelectionTile(
            title: 'Dark Mode',
            isSelected: currentMode == ThemeMode.dark,
            onTap: () => onThemeChanged(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}
