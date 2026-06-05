import '../entities/vocabulary.dart';
import '../entities/morpheme.dart';
import '../entities/body_system.dart';

abstract interface class IVocabularyRepository {
  Future<List<Vocabulary>> getAllVocab();
  Future<List<Vocabulary>> getVocabByDomain(String domain);
  Future<int> countVocabByDomain(String domain);
  Future<List<Vocabulary>> getVocabBySystem(int systemId);
  Future<Vocabulary?> getVocabById(int id);
  Future<List<Vocabulary>> searchVocab(String query, {String? domain});
  Future<List<Vocabulary>> getFlashcardBatch(
      {int? systemId, String? domain, int count = 20});
  Future<List<Morpheme>> getMorphemesForVocab(int vocabId);
  Future<List<BodySystem>> getAllSystems();
  Future<List<BodySystem>> getSystemsByDomain(String domain);
}
