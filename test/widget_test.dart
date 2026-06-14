import 'package:bangla_quran/models/track.dart';
import 'package:bangla_quran/models/playlist_type.dart';
import 'package:bangla_quran/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app theme uses Islamic green as the primary color', () {
    expect(AppTheme.light.colorScheme.primary, AppTheme.islamicGreen);
  });

  test('Track.fromSurahJson maps bundled metadata correctly', () {
    final track = Track.fromSurahJson({
      'number': 1,
      'nameEnglish': 'Al-Fatiha',
      'nameArabic': 'الفاتحة',
      'nameBengali': 'সূরা ফাতিহা',
      'ayahCount': 7,
      'revelationPlace': 'Meccan',
      'audioUrl': '',
    });

    expect(track.id, 'surah_1');
    expect(track.type, PlaylistType.surah);
    expect(track.titleBengali, 'সূরা ফাতিহা');
    expect(track.audioUrl, '');
  });

  test('Track.fromParaJson maps bundled metadata correctly', () {
    final track = Track.fromParaJson({
      'number': 1,
      'nameBengali': 'পারা ১',
      'nameEnglish': 'Juz 1',
      'audioUrl': '',
    });

    expect(track.id, 'para_1');
    expect(track.type, PlaylistType.para);
    expect(track.titleBengali, 'পারা ১');
  });
}
