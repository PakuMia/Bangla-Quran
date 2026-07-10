import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bookmark.dart';
import '../models/surah_info.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage;

  bool _isDark;
  List<SurahInfo> _surahs = [];
  List<Bookmark> _bookmarks = [];
  String _searchQuery = '';
  bool _loaded = false;

  AppProvider(this._storage) : _isDark = _storage.isDarkMode;

  bool get isDark => _isDark;
  List<SurahInfo> get surahs => _surahs;
  List<Bookmark> get bookmarks => _bookmarks;
  bool get loaded => _loaded;
  int? get lastOpenedSurah => _storage.lastOpenedSurah;

  List<SurahInfo> get filteredSurahs {
    if (_searchQuery.isEmpty) return _surahs;
    final q = _searchQuery.toLowerCase();
    return _surahs
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.number.toString().contains(q))
        .toList();
  }

  Future<void> init() async {
    final raw = await rootBundle.loadString('assets/data/surah_pages.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _surahs = list
        .map((e) => SurahInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    _bookmarks = _storage.bookmarks;
    _loaded = true;
    notifyListeners();
  }

  void toggleTheme() {
    _isDark = !_isDark;
    _storage.setDarkMode(_isDark);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  int getLastPage(int surahNumber) => _storage.getLastPage(surahNumber);

  Future<void> saveLastPage(int surahNumber, int page) async {
    await _storage.saveLastPage(surahNumber, page);
    await _storage.saveLastSurah(surahNumber);
  }

  bool isBookmarked(int surahNumber, int page) =>
      _storage.isBookmarked(surahNumber, page);

  Future<void> toggleBookmark(
      int surahNumber, String surahName, int page) async {
    if (_storage.isBookmarked(surahNumber, page)) {
      await _storage.removeBookmark(surahNumber, page);
    } else {
      await _storage.addBookmark(Bookmark(
        surahNumber: surahNumber,
        surahName: surahName,
        page: page,
        savedAt: DateTime.now(),
      ));
    }
    _bookmarks = _storage.bookmarks;
    notifyListeners();
  }

  Future<void> removeBookmark(int surahNumber, int page) async {
    await _storage.removeBookmark(surahNumber, page);
    _bookmarks = _storage.bookmarks;
    notifyListeners();
  }
}
