import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../data/providers.dart';
import '../../../../data/settings_providers.dart';
import '../../../../domain/entities/quiz_question.dart';
import '../../../../domain/entities/wrong_question_entry.dart';

// ── Quiz Session ──────────────────────────────────────────────────────────────

/// Loads [kDefaultQuizSize] random questions for the active domain.
final quizSessionProvider = FutureProvider<List<QuizQuestion>>((ref) {
  final domain = ref.watch(domainProvider);
  return ref
      .watch(quizRepositoryProvider)
      .getRandomQuestions(count: kDefaultQuizSize, domain: domain.name);
});

/// Loads specific questions by their IDs (for wrong-question review).
final quizReviewProvider =
    FutureProvider.family<List<QuizQuestion>, List<int>>((ref, ids) {
  return ref.watch(quizRepositoryProvider).getQuestionsByIds(ids);
});

// ── Wrong Questions ───────────────────────────────────────────────────────────

/// All wrong-question entries for the active domain (streamed so the badge
/// count updates live).
final wrongQuestionsByDomainProvider =
    StreamProvider<List<WrongQuestionEntry>>((ref) {
  final domain = ref.watch(domainProvider);
  return ref
      .watch(wrongQuestionRepositoryProvider)
      .watchByDomain(domain.name);
});

/// Number of active (not-yet-mastered) wrong questions for the active domain.
final wrongQuestionActiveCountProvider = StreamProvider<int>((ref) {
  final domain = ref.watch(domainProvider);
  return ref
      .watch(wrongQuestionRepositoryProvider)
      .watchActiveCount(domain.name);
});
