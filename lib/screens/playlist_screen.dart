import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playlist_type.dart';
import '../services/library_service.dart';
import '../widgets/track_tile.dart';

class PlaylistScreen extends StatelessWidget {
  final PlaylistType type;

  const PlaylistScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryService>();

    if (library.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = library.queueFor(type);

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => TrackTile(track: list[index], queue: list),
    );
  }
}
