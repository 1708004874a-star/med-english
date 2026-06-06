import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_english/core/constants/db_constants.dart';
import 'package:med_english/data/database/app_database.dart';
import 'package:med_english/data/repositories/notebook_repository_impl.dart';

void main() {
  late AppDatabase db;
  late NotebookRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = NotebookRepositoryImpl(db);
  });

  tearDown(() => db.close());

  group('upsertAsLearning', () {
    test('inserts a new entry with MasteryLevel.learning when vocabId not in notebook', () async {
      await repo.upsertAsLearning(99);
      final row = await db.notebookDao.getByVocabId(99);
      expect(row, isNotNull);
      expect(row!.masteryLevel, equals(MasteryLevel.learning.value));
    });

    test('updates mastery to learning when entry already exists at unseen', () async {
      await repo.addEntry(42);
      await repo.upsertAsLearning(42);
      final row = await db.notebookDao.getByVocabId(42);
      expect(row!.masteryLevel, equals(MasteryLevel.learning.value));
    });

    test('downgrades mastery to learning when entry already exists at mastered', () async {
      await repo.addEntry(7);
      final existing = await db.notebookDao.getByVocabId(7);
      await db.notebookDao.updateMastery(existing!.id, MasteryLevel.mastered.value);
      await repo.upsertAsLearning(7);
      final updated = await db.notebookDao.getByVocabId(7);
      expect(updated!.masteryLevel, equals(MasteryLevel.learning.value));
    });

    test('does not create a duplicate entry when called twice', () async {
      await repo.upsertAsLearning(55);
      await repo.upsertAsLearning(55);
      final all = await db.notebookDao.getAll();
      expect(all.where((r) => r.vocabId == 55).length, equals(1));
    });
  });
}
