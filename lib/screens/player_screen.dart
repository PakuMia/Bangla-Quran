import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../models/playlist_type.dart';
import '../providers/player_provider.dart';
import '../services/download_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/queue_sheet.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  String _format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final downloads = context.watch<DownloadManager>();
    final track = player.currentTrack;

    if (player.lastError != null) {
      final error = player.lastError!;
      player.lastError = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      });
    }

    if (track == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('প্লেয়ার')),
        body: const Center(child: Text('কোনো অডিও চলছে না')),
      );
    }

    final isDownloaded = downloads.isDownloaded(track.id);
    final downloadProgress = downloads.progressFor(track.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(track.type == PlaylistType.surah ? 'সূরা প্লেয়ার' : 'পারা প্লেয়ার'),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            tooltip: 'প্লেলিস্ট',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const QueueSheet(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: AppTheme.islamicGreenLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${track.number}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.islamicGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                track.titleBengali,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                track.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = player.duration ?? Duration.zero;
                  final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
                  final value = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

                  return Column(
                    children: [
                      Slider(
                        value: value,
                        max: maxMs,
                        onChanged: (v) => player.seek(Duration(milliseconds: v.toInt())),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_format(position)),
                            Text(_format(duration)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: player.hasPrevious ? player.playPrevious : null,
                  ),
                  StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      final processingState = snapshot.data?.processingState;
                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return const SizedBox(
                          width: 64,
                          height: 64,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return IconButton(
                        iconSize: 64,
                        icon: Icon(
                          playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: AppTheme.islamicGreen,
                        ),
                        onPressed: player.togglePlayPause,
                      );
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: player.hasNext ? player.playNext : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: player.shuffleEnabled ? AppTheme.islamicGreen : Colors.grey,
                    ),
                    tooltip: 'শাফল',
                    onPressed: player.toggleShuffle,
                  ),
                  IconButton(
                    icon: Icon(
                      switch (player.loopMode) {
                        LoopMode.one => Icons.repeat_one_rounded,
                        LoopMode.all => Icons.repeat_rounded,
                        LoopMode.off => Icons.repeat_rounded,
                      },
                      color: player.loopMode == LoopMode.off ? Colors.grey : AppTheme.islamicGreen,
                    ),
                    tooltip: 'রিপিট',
                    onPressed: player.cycleRepeatMode,
                  ),
                  PopupMenuButton<double>(
                    tooltip: 'গতি',
                    initialValue: player.speed,
                    onSelected: player.setSpeed,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 0.75, child: Text('0.75x')),
                      PopupMenuItem(value: 1.0, child: Text('1.0x')),
                      PopupMenuItem(value: 1.25, child: Text('1.25x')),
                      PopupMenuItem(value: 1.5, child: Text('1.5x')),
                      PopupMenuItem(value: 2.0, child: Text('2.0x')),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        '${player.speed.toStringAsFixed(2)}x',
                        style: const TextStyle(
                          color: AppTheme.islamicGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (downloadProgress != null)
                Column(
                  children: [
                    LinearProgressIndicator(value: downloadProgress),
                    const SizedBox(height: 8),
                    Text('ডাউনলোড হচ্ছে... ${(downloadProgress * 100).toStringAsFixed(0)}%'),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: track.audioUrl.isEmpty
                      ? null
                      : () {
                          if (isDownloaded) {
                            downloads.delete(track);
                          } else {
                            downloads.download(track);
                          }
                        },
                  icon: Icon(isDownloaded ? Icons.delete_outline : Icons.download_outlined),
                  label: Text(isDownloaded ? 'ডিলিট করুন' : 'ডাউনলোড করুন'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
