import 'package:flutter/material.dart';

import '../models/playlist_type.dart';
import '../widgets/mini_player.dart';
import 'downloads_screen.dart';
import 'playlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      PlaylistScreen(type: PlaylistType.surah),
      PlaylistScreen(type: PlaylistType.para),
      DownloadsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Bangla Quran')),
      body: Column(
        children: [
          Expanded(child: IndexedStack(index: _index, children: pages)),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'সূরা'),
          BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark), label: 'পারা'),
          BottomNavigationBarItem(icon: Icon(Icons.download_done), label: 'ডাউনলোড'),
        ],
      ),
    );
  }
}
