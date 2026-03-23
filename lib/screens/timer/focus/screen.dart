import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/core/context.dart';
import 'package:rakiz/ui/custom_text.dart';

class FocusContent extends StatelessWidget {
  const FocusContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.bolt_rounded, size: 32, color: context.colorScheme.primary),
        const SizedBox(height: 8),
        UiText(
          text: "Stay focused on your task",
          type: UiTextType.bodyMedium,
          style: GoogleFonts.roboto(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
