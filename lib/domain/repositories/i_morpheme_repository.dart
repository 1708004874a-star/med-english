import '../entities/morpheme.dart';
import '../entities/vocabulary.dart';

abstract interface class IMorphemeRepository {
  Future<List<Morpheme>> getAllMorphemes();
  Future<List<Morpheme>> getMorphemesByDomain(String domain);
  Future<List<Morpheme>> getMorphemesByType(String type, {String? domain});
  Future<Morpheme?> getMorphemeById(int id);
  Future<List<Vocabulary>> getVocabForMorpheme(int morphemeId);
}
