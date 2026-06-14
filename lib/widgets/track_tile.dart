import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';
import '../providers/player_provider.dart';
import '../services/download_manager.dart';
import '../screens/player_screen.dart';
import '../theme/app_theme.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final List<Track> queue;

  const TrackTile({super.key, required this.track, required this.queue});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final downloads = context.watch<DownloadManager>();

    final isCurrent = player.currentTrack?.id == track.id;
    final progress = downloads.progressFor(track.id);
    final isDownloaded = downloads.isDownloaded(track.id);
    final isAvailable = track.audioUrl.isNotEmpty || isDownloaded;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCurrent ? AppTheme.islamicGreen : AppTheme.islamicGreenLight,
        foregroundColor: isCurrent ? Colors.white : AppTheme.islamicGreen,
        child: Text('${track.number}'),
      ),
      title: Text(
        track.titleBengali,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          color: isCurrent ? AppTheme.islamicGreen : null,
        ),
      ),
      subtitle: Text(track.subtitle),
      trailing: progress != null
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: Icon(
                isDownloaded ? Icons.delete_outline : Icons.download_outlined,
                color: isDownloaded ? Colors.redAccent : AppTheme.islamicGreen,
              ),
              onPressed: () {
                if (isDownloaded) {
                  downloads.delete(track);
                } else if (track.audioUrl.isEmpty) {
                  _showUnavailable(context);
                } else {
                  downloads.download(track);
                }
              },
            ),
      onTap: () {
        if (!isAvailable) {
          _showUnavailable(context);
          return;
        }
        player.playTrack(track, queue);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerScreen()));
      },
    );
  }

  void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('এই অডিওটি এখনো আপলোড করা হয়নি')),
    );
  }
}
