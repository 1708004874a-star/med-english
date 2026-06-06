import '../entities/notebook_entry.dart';
import '../../core/constants/db_constants.dart';

abstract interface class INotebookRepository {
  Stream<List<NotebookEntry>> watchAll();
  Future<bool> isInNotebook(int vocabId);
  Future<void> addEntry(int vocabId);
  Future<void> removeEntry(int vocabId);
  Future<void> updateNote(int entryId, String note);
  Future<void> updateMastery(int entryId, MasteryLevel level);
  Future<void> upsertAsLearning(int vocabId);
}
