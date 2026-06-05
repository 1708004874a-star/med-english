import '../../domain/entities/vocabulary.dart';
import '../../domain/entities/morpheme.dart';
import '../../domain/entities/body_system.dart' as entity;
import '../../domain/repositories/i_vocabulary_repository.dart';
import '../../core/constants/db_constants.dart';
import '../database/app_database.dart';

class VocabularyRepositoryImpl implements IVocabularyRepository {
  VocabularyRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Vocabulary>> getAllVocab() async {
    final rows = await _db.vocabularyDao.getAllVocab();
    return Future.wait(rows.map(_toEntity));
  }

  @override
  Future<List<Vocabulary>> getVocabByDomain(String domain) async {
    final rows = await _db.vocabularyDao.getVocabByDomain(domain);
    return Future.wait(rows.map(_toEntity));
  }

  @override
  Future<int> countVocabByDomain(String domain) =>
      _db.vocabularyDao.countVocabByDomain(domain);

  @override
  Future<List<Vocabulary>> getVocabBySystem(int systemId) async {
    final rows = await _db.vocabularyDao.getVocabBySystem(systemId);
    return Future.wait(rows.map(_toEntity));
  }

  @override
  Future<Vocabulary?> getVocabById(int id) async {
    final row = await _db.vocabularyDao.getVocabById(id);
    if (row == null) return null;
    return _toEntity(row);
  }

  @override
  Future<List<Vocabulary>> searchVocab(String query, {String? domain}) async {
    final rows = await _db.vocabularyDao.searchVocab(query, domain: domain);
    return Future.wait(rows.map(_toEntity));
  }

  @override
  Future<List<Vocabulary>> getFlashcardBatch({
    int? systemId,
    String? domain,
    int count = 20,
  }) async {
    final List<VocabularyWord> rows;
    if (systemId != null) {
      rows = await _db.vocabularyDao.getVocabBySystem(systemId);
    } else if (domain != null) {
      rows = await _db.vocabularyDao.getVocabByDomain(domain);
    } else {
      rows = await _db.vocabularyDao.getAllVocab();
    }
    final shuffled = List.of(rows)..shuffle();
    final batch = shuffled.take(count).toList();
    return Future.wait(batch.map(_toEntity));
  }

  @override
  Future<List<Morpheme>> getMorphemesForVocab(int vocabId) async {
    final rows = await _db.morphemeDao.getMorphemesForVocab(vocabId);
    return rows.map(_morphemeToEntity).toList();
  }

  @override
  Future<List<entity.BodySystem>> getAllSystems() async {
    final rows = await _db.vocabularyDao.getAllSystems();
    return rows.map(_systemToEntity).toList();
  }

  @override
  Future<List<entity.BodySystem>> getSystemsByDomain(String domain) async {
    final rows = await _db.vocabularyDao.getSystemsByDomain(domain);
    return rows.map(_systemToEntity).toList();
  }

  Future<Vocabulary> _toEntity(VocabularyWord row) async {
    final morphemeRows =
        await _db.morphemeDao.getMorphemesForVocab(row.id);
    return Vocabulary(
      id: row.id,
      word: row.word,
      pronunciationIpa: row.pronunciationIpa,
      definitionEn: row.definitionEn,
      definitionZh: row.definitionZh,
      exampleEn: row.exampleEn,
      exampleZh: row.exampleZh,
      systemId: row.systemId,
      difficulty: Difficulty.fromValue(row.difficulty),
      morphemes: morphemeRows.map(_morphemeToEntity).toList(),
    );
  }

  Morpheme _morphemeToEntity(WordMorpheme row) => Morpheme(
        id: row.id,
        morpheme: row.morpheme,
        type: MorphemeType.fromString(row.type),
        meaningZh: row.meaningZh,
        meaningEn: row.meaningEn,
        origin: row.origin,
      );

  entity.BodySystem _systemToEntity(BodySystem row) => entity.BodySystem(
        id: row.id,
        nameEn: row.nameEn,
        nameZh: row.nameZh,
        iconName: row.iconName,
        colorHex: row.colorHex,
      );
}
