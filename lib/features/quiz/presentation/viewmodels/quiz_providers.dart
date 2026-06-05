import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../data/providers.dart';
import '../../../../domain/entities/quiz_question.dart';

final quizSessionProvider = FutureProvider<List<QuizQuestion>>((ref) {
  return ref
      .watch(quizRepositoryProvider)
      .getRandomQuestions(count: kDefaultQuizSize);
});
