import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../models/wrong_question_table.dart';
import '../../models/quiz_question_table.dart';

part 'wrong_question_dao.g.dart';

/// A wrong-question record joined with the quiz question it refers to.
class WrongQuestionWithQuestion {
  WrongQuestionWithQuestion(this.wrong, this.question);
  final WrongQuestion wrong;
  final QuizQuestion question;
}

@DriftAccessor(tables: [WrongQuestions, QuizQuestions])
class WrongQuestionDao extends DatabaseAccessor<AppDatabase>
    with _$WrongQuestionDaoMixin {
  WrongQuestionDao(super.db);

  /// Records a wrong answer: insert a new entry, or bump `wrongCount` and
  /// un-master an existing one.
  Future<void> recordWrong(int quizQuestionId, String domain) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await (select(wrongQuestions)
          ..where((t) => t.quizQuestionId.equals(quizQuestionId)))
        .getSingleOrNull();
    if (existing == null) {
      await into(wrongQuestions).insert(WrongQuestionsCompanion.insert(
        quizQuestionId: quizQuestionId,
        domain: domain,
        addedAt: now,
        lastWrongAt: now,
      ));
    } else {
      await (update(wrongQuestions)..where((t) => t.id.equals(existing.id)))
          .write(WrongQuestionsCompanion(
        wrongCount: Value(existing.wrongCount + 1),
        lastWrongAt: Value(now),
        mastered: const Value(false),
      ));
    }
  }

  /// Marks a question mastered (kept in the book, moved out of "to review").
  Future<void> markMastered(int quizQuestionId) async {
    await (update(wrongQuestions)
          ..where((t) => t.quizQuestionId.equals(quizQuestionId)))
        .write(const WrongQuestionsCompanion(mastered: Value(true)));
  }

  /// Moves a mastered question back into the "to review" group.
  Future<void> resetMastered(int quizQuestionId) async {
    await (update(wrongQuestions)
          ..where((t) => t.quizQuestionId.equals(quizQuestionId)))
        .write(const WrongQuestionsCompanion(mastered: Value(false)));
  }

  /// Permanently removes a wrong-question record.
  Future<void> remove(int quizQuestionId) async {
    await (delete(wrongQuestions)
          ..where((t) => t.quizQuestionId.equals(quizQuestionId)))
        .go();
  }

  Stream<List<WrongQuestionWithQuestion>> watchByDomain(String domain) {
    final query = select(wrongQuestions).join([
      innerJoin(quizQuestions,
          quizQuestions.id.equalsExp(wrongQuestions.quizQuestionId)),
    ])
      ..where(wrongQuestions.domain.equals(domain))
      ..orderBy([OrderingTerm.desc(wrongQuestions.lastWrongAt)]);
    return query.watch().map((rows) => rows
        .map((r) => WrongQuestionWithQuestion(
            r.readTable(wrongQuestions), r.readTable(quizQuestions)))
        .toList());
  }

  /// Number of not-yet-mastered wrong questions in [domain] (for the hub badge).
  Stream<int> watchActiveCount(String domain) {
    final count = wrongQuestions.id.count();
    final query = selectOnly(wrongQuestions)
      ..addColumns([count])
      ..where(wrongQuestions.domain.equals(domain) &
          wrongQuestions.mastered.equals(false));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }
}
