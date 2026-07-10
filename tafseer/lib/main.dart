import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'services/storage_service.dart';
import 'screens/surah_list_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.create();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(storage)..init(),
      child: const TafseerApp(),
    ),
  );
}

class TafseerApp extends StatelessWidget {
  const TafseerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().isDark;
    return MaterialApp(
      title: 'তাফসীর ইবনে কাসীর',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const _Loader(),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    final loaded = context.watch<AppProvider>().loaded;
    if (!loaded) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.teal),
        ),
      );
    }
    return const SurahListScreen();
  }
}
