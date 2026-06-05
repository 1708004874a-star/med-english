import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../models/notebook_table.dart';
import '../../models/vocabulary_table.dart';

part 'notebook_dao.g.dart';

@DriftAccessor(tables: [UserNotebook, VocabularyWords])
class NotebookDao extends DatabaseAccessor<AppDatabase>
    with _$NotebookDaoMixin {
  NotebookDao(super.db);

  Stream<List<UserNotebookData>> watchAll() =>
      (select(userNotebook)
            ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
          .watch();

  Future<List<UserNotebookData>> getAll() =>
      (select(userNotebook)
            ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
          .get();

  Future<UserNotebookData?> getByVocabId(int vocabId) =>
      (select(userNotebook)..where((t) => t.vocabId.equals(vocabId)))
          .getSingleOrNull();

  Future<bool> isInNotebook(int vocabId) async {
    final entry = await getByVocabId(vocabId);
    return entry != null;
  }

  Future<int> addEntry(UserNotebookCompanion companion) =>
      into(userNotebook).insert(companion);

  Future<bool> updateEntry(UserNotebookCompanion companion) =>
      update(userNotebook).replace(companion);

  Future<int> removeByVocabId(int vocabId) =>
      (delete(userNotebook)..where((t) => t.vocabId.equals(vocabId))).go();

  Future<int> updateNote(int id, String note) =>
      (update(userNotebook)..where((t) => t.id.equals(id)))
          .write(UserNotebookCompanion(userNote: Value(note)));

  Future<int> updateMastery(int id, int level) =>
      (update(userNotebook)..where((t) => t.id.equals(id)))
          .write(UserNotebookCompanion(masteryLevel: Value(level)));
}
