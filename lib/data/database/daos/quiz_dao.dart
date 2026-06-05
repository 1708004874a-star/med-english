import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../models/quiz_question_table.dart';

part 'quiz_dao.g.dart';

@DriftAccessor(tables: [QuizQuestions])
class QuizDao extends DatabaseAccessor<AppDatabase> with _$QuizDaoMixin {
  QuizDao(super.db);

  Future<List<QuizQuestion>> getAllQuestions() =>
      select(quizQuestions).get();

  Future<List<QuizQuestion>> getRandomQuestions({int count = 10}) async {
    final all = await select(quizQuestions).get();
    all.shuffle();
    return all.take(count).toList();
  }

  Future<List<QuizQuestion>> getQuestionsForVocab(int vocabId) =>
      (select(quizQuestions)
            ..where((t) => t.vocabId.equals(vocabId)))
          .get();

  Future<List<QuizQuestion>> getQuestionsForMorpheme(int morphemeId) =>
      (select(quizQuestions)
            ..where((t) => t.morphemeId.equals(morphemeId)))
          .get();

  Future<void> batchInsertQuestions(
      List<QuizQuestionsCompanion> companions) async {
    await batch((b) => b.insertAll(quizQuestions, companions));
  }
}
