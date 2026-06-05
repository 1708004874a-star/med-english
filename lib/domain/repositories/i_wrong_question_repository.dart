import '../entities/wrong_question_entry.dart';

abstract interface class IWrongQuestionRepository {
  /// Records a wrong answer for [quizQuestionId] under [domain].
  Future<void> recordWrong(int quizQuestionId, String domain);

  /// Marks a question mastered (kept, moved out of the "to review" group).
  Future<void> markMastered(int quizQuestionId);

  /// Moves a mastered question back into "to review".
  Future<void> resetMastered(int quizQuestionId);

  /// Permanently removes a wrong-question record.
  Future<void> remove(int quizQuestionId);

  /// All wrong questions for [domain], newest first.
  Stream<List<WrongQuestionEntry>> watchByDomain(String domain);

  /// Count of not-yet-mastered wrong questions in [domain].
  Stream<int> watchActiveCount(String domain);
}
