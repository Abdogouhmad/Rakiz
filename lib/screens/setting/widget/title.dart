import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/core/context.dart';
import 'package:flutter/material.dart';
import 'package:rakiz/ui/custom_text.dart';

/// section header like section About
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: UiText(
        text: title.toUpperCase(),
        type: UiTextType.labelMedium,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// selection tile
class SelectionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final ctx = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.05)
              : ctx.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : ctx.dividerColor.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UiText(
              text: title,
              type: UiTextType.bodyMedium,
              style: GoogleFonts.roboto(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? colorScheme.primary : null,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
