import 'package:audio_session/audio_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../services/download_manager.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

const _initTimeout = Duration(seconds: 6);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Must happen before any AudioPlayer is created (PlayerProvider creates
    // one lazily on first read below).
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.banglaquran.app.audio',
        androidNotificationChannelName: 'Bangla Quran Playback',
        androidNotificationOngoing: true,
      ).timeout(_initTimeout);
    } catch (_) {
      // Background-audio notifications may not work, but playback itself
      // will still function.
    }

    try {
      await Firebase.initializeApp().timeout(_initTimeout);
    } catch (_) {
      // Firebase isn't configured yet (no google-services.json). The app
      // still works with bundled Surah/Para metadata; see README.
    }

    if (!mounted) return;

    // Configure audio session before creating PlayerProvider/AudioPlayer
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music()).timeout(_initTimeout);
    } catch (_) {
      // Audio session config failed but playback may still work
    }

    if (!mounted) return;
    final downloadManager = context.read<DownloadManager>();
    final library = context.read<LibraryService>();
    final player = context.read<PlayerProvider>();

    try {
      await downloadManager.init().timeout(_initTimeout);
    } catch (_) {}

    try {
      await library.load().timeout(_initTimeout);
      await player.restoreLastSession(library.all).timeout(_initTimeout);
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.islamicGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 96, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Bangla Quran',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'বাংলা অনুবাদ তিলাওয়াত',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
