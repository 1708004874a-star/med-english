class KnowledgeArticle {
  const KnowledgeArticle({
    required this.id,
    required this.systemId,
    required this.titleEn,
    required this.titleZh,
    required this.contentEn,
    required this.contentZh,
    required this.difficulty,
  });

  final int id;
  final int systemId;
  final String titleEn;
  final String titleZh;
  final String contentEn;
  final String contentZh;
  final int difficulty;

  int get estimatedReadMinutes =>
      ((contentEn.split(' ').length) / 200).ceil().clamp(1, 99);

  @override
  bool operator ==(Object other) =>
      other is KnowledgeArticle && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
