class Bookmark {
  final int surahNumber;
  final String surahName;
  final int page;
  final DateTime savedAt;

  Bookmark({
    required this.surahNumber,
    required this.surahName,
    required this.page,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'page': page,
        'savedAt': savedAt.toIso8601String(),
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        surahNumber: json['surahNumber'] as int,
        surahName: json['surahName'] as String,
        page: json['page'] as int,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}
