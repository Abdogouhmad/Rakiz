import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/screens/setting/service/appinfo.dart';
import 'package:rakiz/screens/setting/widget/socialmedia.dart';
import 'package:rakiz/ui/custom_text.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          UiText(
            text: 'About',
            type: UiTextType.headlineLarge,
            style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          UiText(
            text: Appinfo.appname,
            type: UiTextType.bodyMedium,
            style: GoogleFonts.roboto(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          /// App info card
          _Card(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28, // outer bubble size
                  backgroundColor: colors.primaryContainer,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 35,
                      height: 35,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UiText(
                        text: Appinfo.appname,
                        type: UiTextType.titleLarge,
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      UiText(
                        text: 'v${Appinfo.version}',
                        type: UiTextType.labelMedium,
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                SocialBubble(
                  icon: Icons.web_asset_rounded,
                  url: "https://rakizapp.vercel.app/",
                ),
                const SizedBox(width: 8),
                SocialBubble(
                  icon: FontAwesomeIcons.github,
                  url: "https://github.com/Abdogouhmad/Rakiz/",
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// Developer card
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28, // outer bubble size
                      backgroundColor: colors.primaryContainer,
                      backgroundImage: const AssetImage('assets/cat.jpg'),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UiText(
                          text: 'Abdogouhmad',
                          type: UiTextType.titleLarge,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        UiText(
                          text: 'Developer',
                          type: UiTextType.bodySmall,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            SocialBubble(
                              icon: Icons.code,
                              url: "https://github.com/Abdogouhmad",
                            ),
                            SizedBox(width: 8),
                            SocialBubble(
                              icon: FontAwesomeIcons.envelope,
                              url: "mailto:gouhmad@hotmail.com",
                            ),
                            SizedBox(width: 8),
                            SocialBubble(
                              icon: Icons.web_asset_rounded,
                              url: "https://agouhmad.vercel.app/",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // const SizedBox(height: 12),
                // Padding(
                //   padding: EdgeInsetsGeometry.symmetric(horizontal: 20.0),
                //   child: Row(
                //     children: const [
                //       SocialBubble(
                //         icon: Icons.code,
                //         url: "https://github.com/Abdogouhmad",
                //       ),
                //       SizedBox(width: 8),
                //       SocialBubble(
                //         icon: FontAwesomeIcons.envelope,
                //         url: "mailto:gouhmad@hotmail.com",
                //       ),
                //       SizedBox(width: 8),
                //       SocialBubble(
                //         icon: Icons.web_asset_rounded,
                //         url: "https://agouhmad.vercel.app/",
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// Action tiles
          _ActionTile(
            icon: Icons.translate,
            title: 'Help translate ${Appinfo.appname}',
            subtitle: 'Translate the app into your language',
          ),
          _ActionTile(
            icon: Icons.star_rate_rounded,
            title: 'Rate on Google Play',
            subtitle: 'Liked the app? Write a review!',
          ),
          _ActionTile(
            icon: Icons.gavel_rounded,
            title: 'License',
            subtitle: 'GNU General Public License v3',
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new_rounded, size: 18),
        onTap: () {},
      ),
    );
  }
}
