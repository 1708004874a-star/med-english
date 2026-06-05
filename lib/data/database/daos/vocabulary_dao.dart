import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../models/vocabulary_table.dart';
import '../../models/body_system_table.dart';

part 'vocabulary_dao.g.dart';

@DriftAccessor(tables: [VocabularyWords, BodySystems])
class VocabularyDao extends DatabaseAccessor<AppDatabase>
    with _$VocabularyDaoMixin {
  VocabularyDao(super.db);

  Future<List<VocabularyWord>> getAllVocab() =>
      select(vocabularyWords).get();

  Stream<List<VocabularyWord>> watchAllVocab() =>
      select(vocabularyWords).watch();

  Future<List<VocabularyWord>> getVocabBySystem(int systemId) =>
      (select(vocabularyWords)
            ..where((t) => t.systemId.equals(systemId)))
          .get();

  Future<VocabularyWord?> getVocabById(int id) =>
      (select(vocabularyWords)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<VocabularyWord>> searchVocab(String query) =>
      (select(vocabularyWords)
            ..where(
              (t) =>
                  t.word.like('%$query%') |
                  t.definitionEn.like('%$query%'),
            ))
          .get();

  Future<List<VocabularyWord>> getVocabForFlashcards({int limit = 20}) =>
      (select(vocabularyWords)..limit(limit)).get();

  Future<int> insertVocab(VocabularyWordsCompanion companion) =>
      into(vocabularyWords).insert(companion);

  Future<void> batchInsertVocab(
      List<VocabularyWordsCompanion> companions) async {
    await batch((b) => b.insertAll(vocabularyWords, companions));
  }

  Future<List<BodySystem>> getAllSystems() =>
      select(bodySystems).get();

  Future<void> batchInsertSystems(
      List<BodySystemsCompanion> companions) async {
    await batch((b) => b.insertAll(bodySystems, companions));
  }
}
