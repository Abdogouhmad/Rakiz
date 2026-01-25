import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/ui/custom_text.dart';

class License extends StatelessWidget {
  const License({super.key});

  Future<String> _loadLicenseData(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString('assets/LICENSE.md');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Pull Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    UiText(
                      text: "GNU GENERAL PUBLIC LICENSE",
                      textAlign: TextAlign.center,
                      type: UiTextType.headlineSmall,
                      style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    UiText(
                      text: "Version 3, 29 June 2007",
                      textAlign: TextAlign.center,
                      type: UiTextType.titleMedium,
                      style: GoogleFonts.roboto(fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Markdown Content
              Expanded(
                child: FutureBuilder<String>(
                  future: _loadLicenseData(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading license: ${snapshot.error}',
                          style: TextStyle(color: colors.error),
                        ),
                      );
                    }

                    return Markdown(
                      controller: scrollController,
                      data: snapshot.data ?? "No content found.",
                      selectable: true, // Allows users to select and copy text
                      styleSheet: MarkdownStyleSheet(
                        // Headings
                        h1: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                          height: 1.4,
                        ),
                        h2: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                          height: 1.4,
                        ),
                        h3: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                          height: 1.4,
                        ),

                        // Body text
                        p: GoogleFonts.roboto(
                          fontSize: 14,
                          color: colors.onSurface.withValues(alpha: 0.9),
                          height: 1.6,
                        ),

                        // Lists
                        listBullet: GoogleFonts.roboto(
                          fontSize: 14,
                          color: colors.onSurface.withValues(alpha: 0.9),
                        ),

                        // Code blocks
                        code: GoogleFonts.robotoMono(
                          fontSize: 13,
                          backgroundColor: colors.surfaceContainerHighest,
                          color: colors.onSurface,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),

                        // Links
                        a: GoogleFonts.roboto(
                          fontSize: 14,
                          color: colors.primary,
                          decoration: TextDecoration.underline,
                        ),

                        // Spacing
                        blockSpacing: 12.0,
                        listIndent: 24.0,
                        h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
                        h2Padding: const EdgeInsets.only(top: 14, bottom: 6),
                        h3Padding: const EdgeInsets.only(top: 12, bottom: 4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
