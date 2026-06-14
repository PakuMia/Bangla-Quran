import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/playlist_type.dart';
import '../models/track.dart';

/// Loads the bundled Surah/Para metadata and merges in audio URLs that the
/// channel owner publishes to Firestore (collection `tracks`, document id
/// `surah_<n>` / `para_<n>`, field `audioUrl`). This lets new recitations be
/// added without shipping an app update.
class LibraryService extends ChangeNotifier {
  List<Track> surahs = [];
  List<Track> paras = [];
  bool isLoading = true;

  List<Track> get all => [...surahs, ...paras];

  Future<void> load() async {
    final surahJson = await rootBundle.loadString('assets/data/surahs.json');
    final paraJson = await rootBundle.loadString('assets/data/paras.json');

    surahs = (jsonDecode(surahJson) as List)
        .map((e) => Track.fromSurahJson(e as Map<String, dynamic>))
        .toList();
    paras = (jsonDecode(paraJson) as List)
        .map((e) => Track.fromParaJson(e as Map<String, dynamic>))
        .toList();

    await _mergeRemoteAudioUrls();

    isLoading = false;
    notifyListeners();
  }

  Future<void> _mergeRemoteAudioUrls() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('tracks').get();
      final urlMap = <String, String>{};
      for (final doc in snapshot.docs) {
        final url = doc.data()['audioUrl'] as String?;
        if (url != null && url.isNotEmpty) {
          urlMap[doc.id] = url;
        }
      }
      if (urlMap.isEmpty) return;
      surahs = surahs
          .map((t) => urlMap.containsKey(t.id) ? t.copyWithAudioUrl(urlMap[t.id]!) : t)
          .toList();
      paras = paras
          .map((t) => urlMap.containsKey(t.id) ? t.copyWithAudioUrl(urlMap[t.id]!) : t)
          .toList();
    } catch (_) {
      // Firebase not configured yet, or device is offline. The app keeps
      // working with the bundled metadata; audio urls stay empty until
      // Firebase is set up (see README).
    }
  }

  Track? findById(String id) {
    for (final track in all) {
      if (track.id == id) return track;
    }
    return null;
  }

  List<Track> queueFor(PlaylistType type) =>
      type == PlaylistType.surah ? surahs : paras;
}
