import 'playlist_type.dart';

class Track {
  final String id;
  final PlaylistType type;
  final int number;
  final String titleBengali;
  final String titleArabic;
  final String subtitle;
  final int? ayahCount;
  final String audioUrl;

  const Track({
    required this.id,
    required this.type,
    required this.number,
    required this.titleBengali,
    required this.titleArabic,
    required this.subtitle,
    this.ayahCount,
    required this.audioUrl,
  });

  Track copyWithAudioUrl(String url) => Track(
        id: id,
        type: type,
        number: number,
        titleBengali: titleBengali,
        titleArabic: titleArabic,
        subtitle: subtitle,
        ayahCount: ayahCount,
        audioUrl: url,
      );

  factory Track.fromSurahJson(Map<String, dynamic> json) {
    return Track(
      id: 'surah_${json['number']}',
      type: PlaylistType.surah,
      number: json['number'] as int,
      titleBengali: json['nameBengali'] as String,
      titleArabic: json['nameArabic'] as String,
      subtitle: '${json['nameEnglish']} • ${json['ayahCount']} আয়াত',
      ayahCount: json['ayahCount'] as int,
      audioUrl: (json['audioUrl'] as String?) ?? '',
    );
  }

  factory Track.fromParaJson(Map<String, dynamic> json) {
    return Track(
      id: 'para_${json['number']}',
      type: PlaylistType.para,
      number: json['number'] as int,
      titleBengali: json['nameBengali'] as String,
      titleArabic: '',
      subtitle: json['nameEnglish'] as String,
      audioUrl: (json['audioUrl'] as String?) ?? '',
    );
  }
}
