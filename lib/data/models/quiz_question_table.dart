import 'package:drift/drift.dart';
import 'vocabulary_table.dart';
import 'morpheme_table.dart';

class QuizQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // 'multiple_choice' | 'spelling'
  TextColumn get questionEn => text()();
  TextColumn get questionZh => text()();
  TextColumn get optionsJson => text()(); // JSON array of 4 options (en)
  TextColumn get optionsZhJson => text()(); // JSON array of 4 options (zh)
  IntColumn get correctIndex => integer()();
  TextColumn get explanationEn => text()();
  TextColumn get explanationZh => text()();
  IntColumn get vocabId =>
      integer().nullable().references(VocabularyWords, #id)();
  IntColumn get morphemeId =>
      integer().nullable().references(WordMorphemes, #id)();
  TextColumn get domain => text().withDefault(const Constant('macro'))();
}
