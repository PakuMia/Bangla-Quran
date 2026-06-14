import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'providers/player_provider.dart';
import 'screens/splash_screen.dart';
import 'services/download_manager.dart';
import 'services/library_service.dart';
import 'services/playback_storage.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.banglaquran.app.audio',
    androidNotificationChannelName: 'Bangla Quran Playback',
    androidNotificationOngoing: true,
  );

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase isn't configured yet (no google-services.json / firebase
    // options). The app still works with the bundled Surah/Para metadata;
    // see README for enabling remote audio links.
  }

  final storage = PlaybackStorage();
  final downloadManager = DownloadManager(storage);
  await downloadManager.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryService()),
        ChangeNotifierProvider.value(value: downloadManager),
        ChangeNotifierProvider(create: (_) => PlayerProvider(storage, downloadManager)),
      ],
      child: const BanglaQuranApp(),
    ),
  );
}

class BanglaQuranApp extends StatelessWidget {
  const BanglaQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bangla Quran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
