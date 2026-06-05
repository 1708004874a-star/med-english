import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/body_system_table.dart';
import '../models/morpheme_table.dart';
import '../models/vocabulary_table.dart';
import '../models/vocab_morpheme_map.dart';
import '../models/knowledge_article_table.dart';
import '../models/quiz_question_table.dart';
import '../models/notebook_table.dart';
import 'daos/vocabulary_dao.dart';
import 'daos/morpheme_dao.dart';
import 'daos/knowledge_dao.dart';
import 'daos/quiz_dao.dart';
import 'daos/notebook_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    BodySystems,
    WordMorphemes,
    VocabularyWords,
    VocabMorphemeMap,
    KnowledgeArticles,
    QuizQuestions,
    UserNotebook,
  ],
  daos: [
    VocabularyDao,
    MorphemeDao,
    KnowledgeDao,
    QuizDao,
    NotebookDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'medenglish.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
