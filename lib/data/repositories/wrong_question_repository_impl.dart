import 'dart:convert';
import '../../core/constants/db_constants.dart';
import '../../domain/entities/quiz_question.dart' as entity;
import '../../domain/entities/wrong_question_entry.dart';
import '../../domain/repositories/i_wrong_question_repository.dart';
import '../database/app_database.dart';
import '../database/daos/wrong_question_dao.dart';

class WrongQuestionRepositoryImpl implements IWrongQuestionRepository {
  WrongQuestionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> recordWrong(int quizQuestionId, String domain) =>
      _db.wrongQuestionDao.recordWrong(quizQuestionId, domain);

  @override
  Future<void> markMastered(int quizQuestionId) =>
      _db.wrongQuestionDao.markMastered(quizQuestionId);

  @override
  Future<void> resetMastered(int quizQuestionId) =>
      _db.wrongQuestionDao.resetMastered(quizQuestionId);

  @override
  Future<void> remove(int quizQuestionId) =>
      _db.wrongQuestionDao.remove(quizQuestionId);

  @override
  Stream<List<WrongQuestionEntry>> watchByDomain(String domain) {
    return _db.wrongQuestionDao
        .watchByDomain(domain)
        .map((rows) => rows.map(_toEntry).toList());
  }

  @override
  Stream<int> watchActiveCount(String domain) =>
      _db.wrongQuestionDao.watchActiveCount(domain);

  WrongQuestionEntry _toEntry(WrongQuestionWithQuestion row) =>
      WrongQuestionEntry(
        question: _toQuestion(row.question),
        wrongCount: row.wrong.wrongCount,
        mastered: row.wrong.mastered,
        lastWrongAt:
            DateTime.fromMillisecondsSinceEpoch(row.wrong.lastWrongAt),
      );

  entity.QuizQuestion _toQuestion(QuizQuestion row) => entity.QuizQuestion(
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
        domain: row.domain,
      );
}
