import 'package:drift/drift.dart';
import 'vocabulary_table.dart';

class UserNotebook extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vocabId =>
      integer().unique().references(VocabularyWords, #id)();
  IntColumn get addedAt => integer()(); // Unix timestamp (milliseconds)
  TextColumn get userNote =>
      text().withDefault(const Constant(''))();
  IntColumn get masteryLevel =>
      integer().withDefault(const Constant(0))(); // 0–4
}
