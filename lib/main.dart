import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/player_provider.dart';
import 'screens/splash_screen.dart';
import 'services/download_manager.dart';
import 'services/library_service.dart';
import 'services/playback_storage.dart';
import 'theme/app_theme.dart';

/// Renders the first frame immediately, then SplashScreen performs the
/// (potentially slow) Firebase/audio-session setup with timeouts so a
/// misbehaving plugin can never block the UI from showing.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = PlaybackStorage();
  final downloadManager = DownloadManager(storage);

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
