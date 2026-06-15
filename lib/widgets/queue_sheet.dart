import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../theme/app_theme.dart';

/// Bottom sheet listing the current playback queue, with the playing
/// track highlighted and tappable to jump directly to it.
class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final queue = player.queue;
    final current = player.currentTrack;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('প্লেলিস্ট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  final track = queue[index];
                  final isCurrent = track.id == current?.id;
                  final isPlayable = track.audioUrl.isNotEmpty;

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
                        color: isCurrent
                            ? AppTheme.islamicGreen
                            : (isPlayable ? null : Colors.grey),
                      ),
                    ),
                    subtitle: Text(track.subtitle),
                    trailing: isCurrent ? const Icon(Icons.equalizer_rounded, color: AppTheme.islamicGreen) : null,
                    onTap: !isPlayable
                        ? null
                        : () {
                            player.playTrack(track, queue);
                            Navigator.of(context).pop();
                          },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
