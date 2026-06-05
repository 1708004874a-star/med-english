import '../../domain/entities/morpheme.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/repositories/i_morpheme_repository.dart';
import '../../core/constants/db_constants.dart';
import '../database/app_database.dart';

class MorphemeRepositoryImpl implements IMorphemeRepository {
  MorphemeRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Morpheme>> getAllMorphemes() async {
    final rows = await _db.morphemeDao.getAllMorphemes();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<Morpheme>> getMorphemesByType(String type) async {
    final rows = await _db.morphemeDao.getMorphemesByType(type);
    return rows.map(_toEntity).toList();
  }

  @override
  Future<Morpheme?> getMorphemeById(int id) async {
    final row = await _db.morphemeDao.getMorphemeById(id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<List<Vocabulary>> getVocabForMorpheme(int morphemeId) async {
    final rows = await _db.morphemeDao.getVocabForMorpheme(morphemeId);
    return rows
        .map((row) => Vocabulary(
              id: row.id,
              word: row.word,
              pronunciationIpa: row.pronunciationIpa,
              definitionEn: row.definitionEn,
              definitionZh: row.definitionZh,
              exampleEn: row.exampleEn,
              exampleZh: row.exampleZh,
              systemId: row.systemId,
              difficulty: Difficulty.fromValue(row.difficulty),
            ))
        .toList();
  }

  Morpheme _toEntity(WordMorpheme row) => Morpheme(
        id: row.id,
        morpheme: row.morpheme,
        type: MorphemeType.fromString(row.type),
        meaningZh: row.meaningZh,
        meaningEn: row.meaningEn,
        origin: row.origin,
      );
}
