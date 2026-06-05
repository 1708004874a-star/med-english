import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../models/morpheme_table.dart';
import '../../models/vocab_morpheme_map.dart';
import '../../models/vocabulary_table.dart';

part 'morpheme_dao.g.dart';

@DriftAccessor(tables: [WordMorphemes, VocabMorphemeMap, VocabularyWords])
class MorphemeDao extends DatabaseAccessor<AppDatabase>
    with _$MorphemeDaoMixin {
  MorphemeDao(super.db);

  Future<List<WordMorpheme>> getAllMorphemes() =>
      select(wordMorphemes).get();

  Stream<List<WordMorpheme>> watchAllMorphemes() =>
      select(wordMorphemes).watch();

  Future<WordMorpheme?> getMorphemeById(int id) =>
      (select(wordMorphemes)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<WordMorpheme>> getMorphemesByType(String type) =>
      (select(wordMorphemes)..where((t) => t.type.equals(type))).get();

  Future<List<WordMorpheme>> getMorphemesByDomain(String domain) =>
      (select(wordMorphemes)..where((t) => t.domain.equals(domain))).get();

  Future<List<WordMorpheme>> getMorphemesByTypeAndDomain(
          String type, String domain) =>
      (select(wordMorphemes)
            ..where((t) => t.type.equals(type) & t.domain.equals(domain)))
          .get();

  Future<List<VocabularyWord>> getVocabForMorpheme(int morphemeId) {
    final query = select(vocabularyWords).join([
      innerJoin(
        vocabMorphemeMap,
        vocabMorphemeMap.vocabId.equalsExp(vocabularyWords.id),
      ),
    ])
      ..where(vocabMorphemeMap.morphemeId.equals(morphemeId));
    return query.map((row) => row.readTable(vocabularyWords)).get();
  }

  Future<List<WordMorpheme>> getMorphemesForVocab(int vocabId) {
    final query = select(wordMorphemes).join([
      innerJoin(
        vocabMorphemeMap,
        vocabMorphemeMap.morphemeId.equalsExp(wordMorphemes.id),
      ),
    ])
      ..where(vocabMorphemeMap.vocabId.equals(vocabId));
    return query.map((row) => row.readTable(wordMorphemes)).get();
  }

  Future<int> insertMorpheme(WordMorphemesCompanion companion) =>
      into(wordMorphemes).insert(companion);

  Future<void> insertMorphemeMap(VocabMorphemeMapCompanion companion) =>
      into(vocabMorphemeMap).insert(companion);

  Future<void> batchInsertMorphemes(
      List<WordMorphemesCompanion> companions) async {
    await batch((b) => b.insertAll(wordMorphemes, companions));
  }

  Future<void> batchInsertMorphemeMaps(
      List<VocabMorphemeMapCompanion> companions) async {
    await batch((b) => b.insertAll(vocabMorphemeMap, companions));
  }
}
