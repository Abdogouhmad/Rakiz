import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/core/context.dart';
import 'package:rakiz/ui/custom_text.dart';

class BreakContent extends StatelessWidget {
  const BreakContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme; // ← good, short variable name

    return Column(
      mainAxisSize:
          MainAxisSize.min, // ← usually better for this kind of content
      children: [
        Icon(Icons.coffee_rounded, size: 32, color: colorScheme.tertiary),
        const SizedBox(height: 8),
        UiText(
          text: "Time to recharge and stretch",
          type: UiTextType.bodyMedium,
          style: GoogleFonts.roboto(
            color: colorScheme.onSurfaceVariant, // clearest / most readable
            // or: colorScheme.onSurfaceVariant  // slightly softer
          ),
        ),
      ],
    );
  }
}
