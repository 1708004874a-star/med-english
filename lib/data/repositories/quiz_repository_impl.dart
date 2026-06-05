import 'dart:convert';
import '../../domain/entities/quiz_question.dart' as entity;
import '../../domain/repositories/i_quiz_repository.dart';
import '../../core/constants/db_constants.dart';
import '../database/app_database.dart';

class QuizRepositoryImpl implements IQuizRepository {
  QuizRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<entity.QuizQuestion>> getAllQuestions() async {
    final rows = await _db.quizDao.getAllQuestions();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<entity.QuizQuestion>> getRandomQuestions({int count = 10}) async {
    final rows = await _db.quizDao.getRandomQuestions(count: count);
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<entity.QuizQuestion>> getQuestionsForVocab(int vocabId) async {
    final rows = await _db.quizDao.getQuestionsForVocab(vocabId);
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<entity.QuizQuestion>> getQuestionsForMorpheme(int morphemeId) async {
    final rows = await _db.quizDao.getQuestionsForMorpheme(morphemeId);
    return rows.map(_toEntity).toList();
  }

  entity.QuizQuestion _toEntity(QuizQuestion row) => entity.QuizQuestion(
        id: row.id,
        type: QuizType.fromString(row.type),
        questionEn: row.questionEn,
        questionZh: row.questionZh,
        optionsEn: (jsonDecode(row.optionsJson) as List).cast<String>(),
        optionsZh: (jsonDecode(row.optionsZhJson) as List).cast<String>(),
        correctIndex: row.correctIndex,
        explanationEn: row.explanationEn,
        explanationZh: row.explanationZh,
        vocabId: row.vocabId,
        morphemeId: row.morphemeId,
      );
}
