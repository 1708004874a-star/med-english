import '../entities/vocabulary.dart';
import '../entities/morpheme.dart';
import '../entities/body_system.dart';

abstract interface class IVocabularyRepository {
  Future<List<Vocabulary>> getAllVocab();
  Future<List<Vocabulary>> getVocabBySystem(int systemId);
  Future<Vocabulary?> getVocabById(int id);
  Future<List<Vocabulary>> searchVocab(String query);
  Future<List<Vocabulary>> getFlashcardBatch({int? systemId, int count = 20});
  Future<List<Morpheme>> getMorphemesForVocab(int vocabId);
  Future<List<BodySystem>> getAllSystems();
}
