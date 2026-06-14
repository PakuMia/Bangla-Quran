import 'package:shared_preferences/shared_preferences.dart';

class SessionData {
  final String? trackId;
  final int positionMs;

  const SessionData(this.trackId, this.positionMs);
}

/// Persists the user's last playback session and the set of downloaded
/// track ids so playback can resume where the user left off and downloads
/// survive app restarts.
class PlaybackStorage {
  static const _kTrackId = 'last_track_id';
  static const _kPosition = 'last_position_ms';
  static const _kDownloaded = 'downloaded_track_ids';

  Future<void> saveSession(String trackId, int positionMs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTrackId, trackId);
    await prefs.setInt(_kPosition, positionMs);
  }

  Future<SessionData> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    return SessionData(
      prefs.getString(_kTrackId),
      prefs.getInt(_kPosition) ?? 0,
    );
  }

  Future<Set<String>> loadDownloadedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kDownloaded) ?? const []).toSet();
  }

  Future<void> saveDownloadedIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kDownloaded, ids.toList());
  }
}
