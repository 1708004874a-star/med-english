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
import '../models/wrong_question_table.dart';
import 'daos/vocabulary_dao.dart';
import 'daos/morpheme_dao.dart';
import 'daos/knowledge_dao.dart';
import 'daos/quiz_dao.dart';
import 'daos/notebook_dao.dart';
import 'daos/wrong_question_dao.dart';

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
    WrongQuestions,
  ],
  daos: [
    VocabularyDao,
    MorphemeDao,
    KnowledgeDao,
    QuizDao,
    NotebookDao,
    WrongQuestionDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 → v2: dual-system support. Tag existing content as 'macro'
          // (the column default) and add the wrong-questions table.
          if (from < 2) {
            await m.addColumn(bodySystems, bodySystems.domain);
            await m.addColumn(vocabularyWords, vocabularyWords.domain);
            await m.addColumn(wordMorphemes, wordMorphemes.domain);
            await m.addColumn(knowledgeArticles, knowledgeArticles.domain);
            await m.addColumn(quizQuestions, quizQuestions.domain);
            await m.createTable(wrongQuestions);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'medenglish.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
