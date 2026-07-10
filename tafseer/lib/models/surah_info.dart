class SurahInfo {
  final int number;
  final String name;
  final String arabicName;
  final int ayat;
  final String type;
  final int page;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.ayat,
    required this.type,
    required this.page,
  });

  factory SurahInfo.fromJson(Map<String, dynamic> json) => SurahInfo(
        number: json['number'] as int,
        name: json['name'] as String,
        arabicName: json['arabicName'] as String,
        ayat: json['ayat'] as int,
        type: json['type'] as String,
        page: json['page'] as int,
      );
}
