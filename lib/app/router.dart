import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/vocabulary/presentation/screens/vocab_list_screen.dart';
import '../features/vocabulary/presentation/screens/vocab_detail_screen.dart';
import '../features/vocabulary/presentation/screens/morpheme_list_screen.dart';
import '../features/vocabulary/presentation/screens/morpheme_detail_screen.dart';
import '../features/flashcard/presentation/screens/flashcard_session_screen.dart';
import '../features/flashcard/presentation/screens/session_complete_screen.dart';
import '../features/knowledge/presentation/screens/systems_grid_screen.dart';
import '../features/knowledge/presentation/screens/article_list_screen.dart';
import '../features/knowledge/presentation/screens/article_detail_screen.dart';
import '../features/quiz/presentation/screens/quiz_hub_screen.dart';
import '../features/quiz/presentation/screens/quiz_session_screen.dart';
import '../features/quiz/presentation/screens/quiz_result_screen.dart';
import '../features/quiz/presentation/screens/wrong_questions_screen.dart';
import '../features/notebook/presentation/screens/notebook_list_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import 'shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScaffold(navigationShell: navigationShell),
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Vocabulary (words + morphemes)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/vocabulary',
              builder: (context, state) => const VocabListScreen(),
              routes: [
                GoRoute(
                  path: 'morphemes',
                  builder: (context, state) => const MorphemeListScreen(),
                  routes: [
                    GoRoute(
                      path: ':morphemeId',
                      builder: (context, state) => MorphemeDetailScreen(
                        morphemeId:
                            int.parse(state.pathParameters['morphemeId']!),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: ':vocabId',
                  builder: (context, state) => VocabDetailScreen(
                    vocabId: int.parse(state.pathParameters['vocabId']!),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Tab 2: Knowledge base
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/knowledge',
              builder: (context, state) => const SystemsGridScreen(),
              routes: [
                GoRoute(
                  path: ':systemId',
                  builder: (context, state) => ArticleListScreen(
                    systemId: int.parse(state.pathParameters['systemId']!),
                  ),
                  routes: [
                    GoRoute(
                      path: ':articleId',
                      builder: (context, state) => ArticleDetailScreen(
                        articleId:
                            int.parse(state.pathParameters['articleId']!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Tab 3: Notebook
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notebook',
              builder: (context, state) => const NotebookListScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Full-screen routes (outside the shell / no bottom nav) ────────────

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/flashcard',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return FlashcardSessionScreen(
          systemId: extra?['systemId'] as int?,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/flashcard/complete',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return SessionCompleteScreen(
          correct: extra['correct'] as int,
          total: extra['total'] as int,
        );
      },
    ),

    // ── Quiz routes ───────────────────────────────────────────────────────

    // Hub: choose between starting a quiz and reviewing wrong questions.
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/quiz',
      builder: (context, state) => const QuizHubScreen(),
    ),

    // Normal quiz session (random questions from the active domain).
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/quiz/session',
      builder: (context, state) => const QuizSessionScreen(),
    ),

    // Review session (redo specific wrong questions).
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/quiz/session/review',
      builder: (context, state) {
        final ids = (state.extra as List).cast<int>();
        return QuizSessionScreen(questionIds: ids);
      },
    ),

    // Wrong-question book.
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/quiz/wrong',
      builder: (context, state) => const WrongQuestionsScreen(),
    ),

    // Quiz results.
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/quiz/result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return QuizResultScreen(
          correct: extra['correct'] as int,
          total: extra['total'] as int,
          wrongIds: (extra['wrongIds'] as List).cast<int>(),
        );
      },
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
