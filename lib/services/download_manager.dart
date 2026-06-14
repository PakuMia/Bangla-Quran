import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/track.dart';
import 'playback_storage.dart';

/// Downloads recitation audio for offline listening and keeps track of
/// which tracks are already available on-device.
class DownloadManager extends ChangeNotifier {
  final PlaybackStorage _storage;
  final Dio _dio = Dio();

  Set<String> _downloadedIds = {};
  final Map<String, double> _progress = {};

  DownloadManager(this._storage);

  Future<void> init() async {
    _downloadedIds = await _storage.loadDownloadedIds();
    notifyListeners();
  }

  bool isDownloaded(String trackId) => _downloadedIds.contains(trackId);

  double? progressFor(String trackId) => _progress[trackId];

  Future<String> _filePath(String trackId) async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return '${audioDir.path}/$trackId.mp3';
  }

  Future<String?> localPath(String trackId) async {
    if (!_downloadedIds.contains(trackId)) return null;
    final path = await _filePath(trackId);
    return File(path).existsSync() ? path : null;
  }

  Future<void> download(Track track) async {
    if (track.audioUrl.isEmpty || isDownloaded(track.id)) return;

    final path = await _filePath(track.id);
    _progress[track.id] = 0;
    notifyListeners();

    try {
      await _dio.download(
        track.audioUrl,
        path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _progress[track.id] = received / total;
            notifyListeners();
          }
        },
      );
      _downloadedIds.add(track.id);
      await _storage.saveDownloadedIds(_downloadedIds);
    } catch (_) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } finally {
      _progress.remove(track.id);
      notifyListeners();
    }
  }

  Future<void> delete(Track track) async {
    final path = await _filePath(track.id);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    _downloadedIds.remove(track.id);
    await _storage.saveDownloadedIds(_downloadedIds);
    notifyListeners();
  }
}
