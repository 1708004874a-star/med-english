import '../../core/constants/db_constants.dart';
import 'morpheme.dart';

class Vocabulary {
  const Vocabulary({
    required this.id,
    required this.word,
    this.pronunciationIpa,
    required this.definitionEn,
    required this.definitionZh,
    this.exampleEn,
    this.exampleZh,
    this.systemId,
    required this.difficulty,
    this.morphemes = const [],
  });

  final int id;
  final String word;
  final String? pronunciationIpa;
  final String definitionEn;
  final String definitionZh;
  final String? exampleEn;
  final String? exampleZh;
  final int? systemId;
  final Difficulty difficulty;
  final List<Morpheme> morphemes;

  Vocabulary copyWith({List<Morpheme>? morphemes}) {
    return Vocabulary(
      id: id,
      word: word,
      pronunciationIpa: pronunciationIpa,
      definitionEn: definitionEn,
      definitionZh: definitionZh,
      exampleEn: exampleEn,
      exampleZh: exampleZh,
      systemId: systemId,
      difficulty: difficulty,
      morphemes: morphemes ?? this.morphemes,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Vocabulary && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
