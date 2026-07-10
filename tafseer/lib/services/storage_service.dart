import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';

class StorageService {
  static const _themeKey = 'isDarkMode';
  static const _lastReadKey = 'lastRead_';
  static const _lastSurahKey = 'lastSurah';
  static const _bookmarksKey = 'bookmarks';
  static const _pdfUrlKey = 'pdfUrl';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  bool get isDarkMode => _prefs.getBool(_themeKey) ?? true;
  Future<void> setDarkMode(bool value) => _prefs.setBool(_themeKey, value);

  int getLastPage(int surahNumber) =>
      _prefs.getInt('$_lastReadKey$surahNumber') ?? 0;

  Future<void> saveLastPage(int surahNumber, int page) =>
      _prefs.setInt('$_lastReadKey$surahNumber', page);

  int? get lastOpenedSurah => _prefs.getInt(_lastSurahKey);
  Future<void> saveLastSurah(int number) =>
      _prefs.setInt(_lastSurahKey, number);

  List<Bookmark> get bookmarks {
    final raw = _prefs.getStringList(_bookmarksKey) ?? [];
    return raw
        .map((e) => Bookmark.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    final list = bookmarks;
    list.removeWhere(
      (b) => b.surahNumber == bookmark.surahNumber && b.page == bookmark.page,
    );
    list.insert(0, bookmark);
    await _prefs.setStringList(
      _bookmarksKey,
      list.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }

  Future<void> removeBookmark(int surahNumber, int page) async {
    final list = bookmarks;
    list.removeWhere((b) => b.surahNumber == surahNumber && b.page == page);
    await _prefs.setStringList(
      _bookmarksKey,
      list.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }

  bool isBookmarked(int surahNumber, int page) =>
      bookmarks.any((b) => b.surahNumber == surahNumber && b.page == page);

  String get pdfUrl => _prefs.getString(_pdfUrlKey) ?? '';
  Future<void> setPdfUrl(String url) => _prefs.setString(_pdfUrlKey, url);
}
