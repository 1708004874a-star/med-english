import 'quiz_question.dart';

/// A quiz question the user got wrong, with review metadata.
class WrongQuestionEntry {
  const WrongQuestionEntry({
    required this.question,
    required this.wrongCount,
    required this.mastered,
    required this.lastWrongAt,
  });

  final QuizQuestion question;
  final int wrongCount;
  final bool mastered;
  final DateTime lastWrongAt;
}
