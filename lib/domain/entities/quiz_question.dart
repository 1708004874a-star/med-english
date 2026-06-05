import '../../core/constants/db_constants.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.type,
    required this.questionEn,
    required this.questionZh,
    required this.optionsEn,
    required this.optionsZh,
    required this.correctIndex,
    required this.explanationEn,
    required this.explanationZh,
    this.vocabId,
    this.morphemeId,
    this.domain = 'macro',
  });

  final int id;
  final QuizType type;
  final String questionEn;
  final String questionZh;
  final List<String> optionsEn;
  final List<String> optionsZh;
  final int correctIndex;
  final String explanationEn;
  final String explanationZh;
  final int? vocabId;
  final int? morphemeId;
  final String domain;

  String get correctAnswerEn => optionsEn[correctIndex];
  String get correctAnswerZh => optionsZh[correctIndex];

  @override
  bool operator ==(Object other) =>
      other is QuizQuestion && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
