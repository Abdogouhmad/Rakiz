import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaSection extends StatelessWidget {
  const SocialMediaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 24,
        children: [
          _SocialIcon(
            icon: FontAwesomeIcons.github,
            url: "https://github.com/Abdogouhmad/Rakiz",
          ),
          _SocialIcon(
            icon: FontAwesomeIcons.bluesky,
            url: "https://bsky.app/profile/3bdo23.bsky.social",
          ),
          _SocialIcon(
            icon: FontAwesomeIcons.squareXTwitter,
            url: "https://x.com/a3bdor7man",
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url; // accept string directly

  const _SocialIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    Future<void> launchInBrowser(String urlString) async {
      final uri = Uri.parse(urlString); // parse string to Uri here
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $urlString');
      }
    }

    return InkResponse(
      radius: 28,
      onTap: () => launchInBrowser(url),
      child: FaIcon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
    );
  }
}
