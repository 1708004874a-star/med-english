import '../../domain/entities/notebook_entry.dart';
import '../../domain/repositories/i_notebook_repository.dart';
import '../../core/constants/db_constants.dart';
import '../database/app_database.dart';

class NotebookRepositoryImpl implements INotebookRepository {
  NotebookRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<NotebookEntry>> watchAll() {
    return _db.notebookDao.watchAll().map(
          (rows) => rows.map(_toEntity).toList(),
        );
  }

  @override
  Future<bool> isInNotebook(int vocabId) =>
      _db.notebookDao.isInNotebook(vocabId);

  @override
  Future<void> addEntry(int vocabId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.notebookDao.addEntry(
      UserNotebookCompanion.insert(
        vocabId: vocabId,
        addedAt: now,
      ),
    );
  }

  @override
  Future<void> removeEntry(int vocabId) async {
    await _db.notebookDao.removeByVocabId(vocabId);
  }

  @override
  Future<void> updateNote(int entryId, String note) async {
    await _db.notebookDao.updateNote(entryId, note);
  }

  @override
  Future<void> updateMastery(int entryId, MasteryLevel level) async {
    await _db.notebookDao.updateMastery(entryId, level.value);
  }

  NotebookEntry _toEntity(UserNotebookData row) => NotebookEntry(
        id: row.id,
        vocabId: row.vocabId,
        addedAt: DateTime.fromMillisecondsSinceEpoch(row.addedAt),
        userNote: row.userNote,
        masteryLevel: MasteryLevel.values[row.masteryLevel.clamp(0, 4)],
      );
}
