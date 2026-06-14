import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/download_manager.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/track_tile.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryService>();
    final downloads = context.watch<DownloadManager>();

    if (library.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final downloaded = library.all.where((t) => downloads.isDownloaded(t.id)).toList();

    if (downloaded.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_outlined, size: 56, color: AppTheme.islamicGreen),
              SizedBox(height: 12),
              Text('কোনো অডিও ডাউনলোড করা হয়নি', textAlign: TextAlign.center),
              SizedBox(height: 4),
              Text(
                'অফলাইনে শোনার জন্য সূরা বা পারা থেকে ডাউনলোড আইকনে চাপুন',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: downloaded.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final track = downloaded[index];
        return TrackTile(track: track, queue: library.queueFor(track.type));
      },
    );
  }
}
