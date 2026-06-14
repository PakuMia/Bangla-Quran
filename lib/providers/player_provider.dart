import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/playlist_type.dart';
import '../models/track.dart';
import '../services/download_manager.dart';
import '../services/playback_storage.dart';

/// Drives audio playback, keeps the current Surah/Para queue, and
/// continuously persists the current track + position so playback can
/// resume exactly where the user left off, even after the app is closed.
class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final PlaybackStorage _storage;
  final DownloadManager _downloadManager;

  List<Track> _queue = [];
  Track? currentTrack;

  DateTime _lastSaved = DateTime.fromMillisecondsSinceEpoch(0);

  PlayerProvider(this._storage, this._downloadManager) {
    _player.playerStateStream.listen((_) => notifyListeners());
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
    _player.positionStream.listen((position) {
      _maybeSavePosition(position);
    });
  }

  AudioPlayer get player => _player;
  List<Track> get queue => _queue;
  bool get isPlaying => _player.playing;
  Duration? get duration => _player.duration;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  bool get hasNext {
    if (currentTrack == null || _queue.isEmpty) return false;
    final index = _queue.indexWhere((t) => t.id == currentTrack!.id);
    return index != -1 && index < _queue.length - 1;
  }

  bool get hasPrevious {
    if (currentTrack == null || _queue.isEmpty) return false;
    final index = _queue.indexWhere((t) => t.id == currentTrack!.id);
    return index > 0;
  }

  Future<void> playTrack(Track track, List<Track> queue, {Duration? startAt}) async {
    _queue = queue;
    currentTrack = track;
    notifyListeners();

    await _setSource(track, startAt: startAt ?? Duration.zero);
    await _player.play();
    await _storage.saveSession(track.id, (startAt ?? Duration.zero).inMilliseconds);
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    if (currentTrack != null) {
      await _storage.saveSession(currentTrack!.id, position.inMilliseconds);
    }
  }

  Future<void> playNext() async {
    if (!hasNext) return;
    final index = _queue.indexWhere((t) => t.id == currentTrack!.id);
    await playTrack(_queue[index + 1], _queue);
  }

  Future<void> playPrevious() async {
    if (!hasPrevious) return;
    final index = _queue.indexWhere((t) => t.id == currentTrack!.id);
    await playTrack(_queue[index - 1], _queue);
  }

  /// Restores the last played track (and position) on app launch without
  /// auto-playing, so the user lands exactly where they left off.
  Future<void> restoreLastSession(List<Track> allTracks) async {
    final session = await _storage.loadSession();
    if (session.trackId == null) return;

    final track = allTracks.where((t) => t.id == session.trackId).firstOrNull;
    if (track == null) return;

    final localPath = await _downloadManager.localPath(track.id);
    if (track.audioUrl.isEmpty && localPath == null) return;

    currentTrack = track;
    _queue = track.type == PlaylistType.surah
        ? allTracks.where((t) => t.type == PlaylistType.surah).toList()
        : allTracks.where((t) => t.type == PlaylistType.para).toList();

    await _setSource(track, startAt: Duration(milliseconds: session.positionMs), play: false);
    notifyListeners();
  }

  Future<void> _setSource(Track track, {Duration startAt = Duration.zero, bool play = true}) async {
    final localPath = await _downloadManager.localPath(track.id);
    final source = localPath != null
        ? AudioSource.uri(Uri.file(localPath), tag: _mediaItem(track))
        : AudioSource.uri(Uri.parse(track.audioUrl), tag: _mediaItem(track));

    await _player.setAudioSource(source, initialPosition: startAt);
  }

  MediaItem _mediaItem(Track track) => MediaItem(
        id: track.id,
        title: track.titleBengali,
        artist: 'Bangla Quran',
        album: track.subtitle,
      );

  void _onTrackCompleted() {
    if (hasNext) {
      playNext();
    } else if (currentTrack != null) {
      _storage.saveSession(currentTrack!.id, 0);
    }
  }

  void _maybeSavePosition(Duration position) {
    if (currentTrack == null) return;
    final now = DateTime.now();
    if (now.difference(_lastSaved).inSeconds < 3) return;
    _lastSaved = now;
    _storage.saveSession(currentTrack!.id, position.inMilliseconds);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
