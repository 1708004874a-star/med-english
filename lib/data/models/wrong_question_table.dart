import 'package:drift/drift.dart';
import 'quiz_question_table.dart';

/// Tracks quiz questions the user answered incorrectly, grouped by [domain].
///
/// This is user data — like `user_notebook`, it is NOT cleared when the bundled
/// seed content is re-imported. A question stays here once added; answering it
/// correctly during a review session sets [mastered] (it is kept, not deleted,
/// so the user keeps a record of what they've conquered).
class WrongQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get quizQuestionId =>
      integer().unique().references(QuizQuestions, #id)();
  TextColumn get domain => text()(); // 'macro' | 'micro'
  IntColumn get wrongCount => integer().withDefault(const Constant(1))();
  IntColumn get addedAt => integer()(); // Unix ms
  IntColumn get lastWrongAt => integer()(); // Unix ms
  BoolColumn get mastered => boolean().withDefault(const Constant(false))();
}
