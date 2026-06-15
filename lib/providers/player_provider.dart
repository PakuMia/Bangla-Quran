import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/playlist_type.dart';
import '../models/track.dart';
import '../services/download_manager.dart';
import '../services/playback_storage.dart';

/// Drives audio playback, keeps the current Surah/Para queue, and
/// continuously persists the current track + position so playback can
/// resume exactly where the user left off, even after the app is closed.
///
/// Playback uses a [ConcatenatingAudioSource] so that just_audio_background
/// can show working skip-to-next/previous controls on the lock screen, and
/// so native shuffle/repeat (loop) modes work correctly.
class PlayerProvider extends ChangeNotifier {
  late final AudioPlayer _player;
  final PlaybackStorage _storage;
  final DownloadManager _downloadManager;

  List<Track> _queue = [];
  List<Track> _playable = [];
  Track? currentTrack;

  DateTime _lastSaved = DateTime.fromMillisecondsSinceEpoch(0);

  String? lastError;

  PlayerProvider(this._storage, this._downloadManager) {
    _player = AudioPlayer();
    _configureAudioSession();

    _player.playerStateStream.listen((_) => notifyListeners());
    _player.loopModeStream.listen((_) => notifyListeners());
    _player.shuffleModeEnabledStream.listen((_) => notifyListeners());
    _player.speedStream.listen((_) => notifyListeners());
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
    _player.positionStream.listen((position) {
      _maybeSavePosition(position);
    });
    _player.currentIndexStream.listen((index) {
      if (index == null || index >= _playable.length) return;
      final track = _playable[index];
      if (currentTrack?.id != track.id) {
        currentTrack = track;
        _storage.saveSession(track.id, 0);
        notifyListeners();
      }
    });
  }

  void _configureAudioSession() {
    AudioSession.instance.then((session) {
      session.configure(const AudioSessionConfiguration.music()).catchError(
        (e) => debugPrint('Audio session config failed: $e'),
      );
    });
  }

  AudioPlayer get player => _player;
  List<Track> get queue => _queue;
  bool get isPlaying => _player.playing;
  Duration? get duration => _player.duration;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  bool get hasNext => _player.hasNext;
  bool get hasPrevious => _player.hasPrevious;

  bool get shuffleEnabled => _player.shuffleModeEnabled;
  LoopMode get loopMode => _player.loopMode;
  double get speed => _player.speed;

  Future<void> playTrack(Track track, List<Track> queue, {Duration? startAt}) async {
    _queue = queue;
    currentTrack = track;
    lastError = null;
    notifyListeners();

    try {
      _playable = queue
          .where((t) => t.audioUrl.isNotEmpty || _downloadManager.isDownloaded(t.id))
          .toList();
      if (_playable.indexWhere((t) => t.id == track.id) == -1) {
        _playable = [track, ..._playable];
      }

      final sources = await Future.wait(_playable.map(_audioSourceFor));
      final playlist = ConcatenatingAudioSource(children: sources);
      final initialIndex = _playable.indexWhere((t) => t.id == track.id);

      await _player.setAudioSource(
        playlist,
        initialIndex: initialIndex < 0 ? 0 : initialIndex,
        initialPosition: startAt ?? Duration.zero,
      );
      await _player.play();
      await _storage.saveSession(track.id, (startAt ?? Duration.zero).inMilliseconds);
    } catch (e) {
      lastError = 'অডিও চালানো যাচ্ছে না: $e';
      notifyListeners();
    }
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
    await _player.seekToNext();
  }

  Future<void> playPrevious() async {
    await _player.seekToPrevious();
  }

  /// Cycles repeat mode: off -> repeat all -> repeat one -> off.
  Future<void> cycleRepeatMode() async {
    final next = switch (_player.loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _player.setLoopMode(next);
  }

  Future<void> toggleShuffle() async {
    await _player.setShuffleModeEnabled(!_player.shuffleModeEnabled);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
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

    final queue = track.type == PlaylistType.surah
        ? allTracks.where((t) => t.type == PlaylistType.surah).toList()
        : allTracks.where((t) => t.type == PlaylistType.para).toList();

    _queue = queue;
    currentTrack = track;
    try {
      _playable = queue
          .where((t) => t.audioUrl.isNotEmpty || _downloadManager.isDownloaded(t.id))
          .toList();
      if (_playable.indexWhere((t) => t.id == track.id) == -1) {
        _playable = [track, ..._playable];
      }

      final sources = await Future.wait(_playable.map(_audioSourceFor));
      final playlist = ConcatenatingAudioSource(children: sources);
      final initialIndex = _playable.indexWhere((t) => t.id == track.id);

      await _player.setAudioSource(
        playlist,
        initialIndex: initialIndex < 0 ? 0 : initialIndex,
        initialPosition: Duration(milliseconds: session.positionMs),
      );
    } catch (_) {
      // Couldn't restore the previous source (e.g. no network); the user
      // can still browse and pick a track to play.
    }
    notifyListeners();
  }

  Future<AudioSource> _audioSourceFor(Track track) async {
    final localPath = await _downloadManager.localPath(track.id);
    return localPath != null
        ? AudioSource.uri(Uri.file(localPath), tag: _mediaItem(track))
        : AudioSource.uri(Uri.parse(track.audioUrl), tag: _mediaItem(track));
  }

  MediaItem _mediaItem(Track track) => MediaItem(
        id: track.id,
        title: track.titleBengali,
        artist: 'Bangla Quran',
        album: track.subtitle,
      );

  void _onTrackCompleted() {
    if (currentTrack != null && !hasNext && _player.loopMode == LoopMode.off) {
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
