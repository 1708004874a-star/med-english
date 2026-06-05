import 'package:drift/drift.dart';
import 'vocabulary_table.dart';
import 'morpheme_table.dart';

class VocabMorphemeMap extends Table {
  IntColumn get vocabId =>
      integer().references(VocabularyWords, #id)();
  IntColumn get morphemeId =>
      integer().references(WordMorphemes, #id)();

  @override
  Set<Column> get primaryKey => {vocabId, morphemeId};
}
