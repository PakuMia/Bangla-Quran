import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

/// Side menu with links to the YouTube channel and other promoted
/// platforms/links. Add more [_DrawerLink] entries below to promote
/// additional channels, social pages, or businesses.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _links = [
    _DrawerLink(
      icon: Icons.smart_display_rounded,
      label: 'YouTube চ্যানেল',
      url: 'https://www.youtube.com/@BanglaQuran',
    ),
    _DrawerLink(
      icon: Icons.share_rounded,
      label: 'অ্যাপটি শেয়ার করুন',
      url: 'https://github.com/PakuMia/Bangla-Quran',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.islamicGreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.menu_book_rounded, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Bangla Quran',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'বাংলা অনুবাদ তিলাওয়াত',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            for (final link in _links)
              ListTile(
                leading: Icon(link.icon, color: AppTheme.islamicGreen),
                title: Text(link.label),
                onTap: () => _open(context, link.url),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('লিংক খোলা যায়নি')),
      );
    }
  }
}

class _DrawerLink {
  final IconData icon;
  final String label;
  final String url;

  const _DrawerLink({required this.icon, required this.label, required this.url});
}
