class NameOfAllah {
  final int number;
  final String nameArabic;
  final String nameTransliteration;
  final String nameBengali;
  final String meaningBengali;

  const NameOfAllah({
    required this.number,
    required this.nameArabic,
    required this.nameTransliteration,
    required this.nameBengali,
    required this.meaningBengali,
  });

  factory NameOfAllah.fromJson(Map<String, dynamic> json) {
    return NameOfAllah(
      number: json['number'] as int,
      nameArabic: json['nameArabic'] as String,
      nameTransliteration: json['nameTransliteration'] as String,
      nameBengali: json['nameBengali'] as String,
      meaningBengali: json['meaningBengali'] as String,
    );
  }
}
