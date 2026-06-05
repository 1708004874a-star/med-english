import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/app_database.dart';
import 'seed/db_seeder.dart';
import 'repositories/vocabulary_repository_impl.dart';
import 'repositories/morpheme_repository_impl.dart';
import 'repositories/knowledge_repository_impl.dart';
import 'repositories/notebook_repository_impl.dart';
import 'repositories/quiz_repository_impl.dart';
import 'repositories/wrong_question_repository_impl.dart';
import '../domain/repositories/i_vocabulary_repository.dart';
import '../domain/repositories/i_morpheme_repository.dart';
import '../domain/repositories/i_knowledge_repository.dart';
import '../domain/repositories/i_notebook_repository.dart';
import '../domain/repositories/i_quiz_repository.dart';
import '../domain/repositories/i_wrong_question_repository.dart';

// ── Database ──────────────────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) {
    final db = AppDatabase();
    ref.onDispose(db.close);
    return db;
  },
);

// ── Repositories ─────────────────────────────────────────────────────────────

final vocabularyRepositoryProvider = Provider<IVocabularyRepository>(
  (ref) => VocabularyRepositoryImpl(ref.watch(appDatabaseProvider)),
);

final morphemeRepositoryProvider = Provider<IMorphemeRepository>(
  (ref) => MorphemeRepositoryImpl(ref.watch(appDatabaseProvider)),
);

final knowledgeRepositoryProvider = Provider<IKnowledgeRepository>(
  (ref) => KnowledgeRepositoryImpl(ref.watch(appDatabaseProvider)),
);

final notebookRepositoryProvider = Provider<INotebookRepository>(
  (ref) => NotebookRepositoryImpl(ref.watch(appDatabaseProvider)),
);

final quizRepositoryProvider = Provider<IQuizRepository>(
  (ref) => QuizRepositoryImpl(ref.watch(appDatabaseProvider)),
);

final wrongQuestionRepositoryProvider = Provider<IWrongQuestionRepository>(
  (ref) => WrongQuestionRepositoryImpl(ref.watch(appDatabaseProvider)),
);

// ── App Initialization ────────────────────────────────────────────────────────

final appInitProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  await DbSeeder(db).seedIfNeeded();
});
