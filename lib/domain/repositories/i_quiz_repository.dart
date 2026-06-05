import '../entities/quiz_question.dart';

abstract interface class IQuizRepository {
  Future<List<QuizQuestion>> getAllQuestions();
  Future<List<QuizQuestion>> getRandomQuestions({int count = 10});
  Future<List<QuizQuestion>> getQuestionsForVocab(int vocabId);
  Future<List<QuizQuestion>> getQuestionsForMorpheme(int morphemeId);
}
