class KanjiCard {
  const KanjiCard(
      {required this.id,
      required this.kanji,
      required this.level,
      required this.meaningKo,
      required this.onReadings,
      required this.kunReadings,
      required this.strokeCount,
      required this.radicalNumber,
      this.imageUrl,
      this.remoteContent});
  final String id;
  final String kanji;
  final String level;
  final String meaningKo;
  final List<String> onReadings;
  final List<String> kunReadings;
  final int strokeCount;
  final int radicalNumber;
  final String? imageUrl;
  final String? remoteContent;

  factory KanjiCard.fromJson(Map<String, dynamic> json) => KanjiCard(
        id: json['id'] as String,
        kanji: json['kanji'] as String,
        level: json['level'] as String? ?? 'N5',
        meaningKo: json['meaningKo'] as String? ?? '',
        onReadings: List<String>.from(json['onReadings'] as List? ?? const []),
        kunReadings:
            List<String>.from(json['kunReadings'] as List? ?? const []),
        strokeCount: json['strokeCount'] as int? ?? 0,
        radicalNumber: json['radicalNumber'] as int? ?? 0,
      );
}
