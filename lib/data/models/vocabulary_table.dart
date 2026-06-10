import 'package:drift/drift.dart';
import 'body_system_table.dart';

class VocabularyWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
  TextColumn get pronunciationIpa => text().nullable()();
  TextColumn get definitionEn => text()();
  TextColumn get definitionZh => text()();
  TextColumn get exampleEn => text().nullable()();
  TextColumn get exampleZh => text().nullable()();
  IntColumn get systemId =>
      integer().nullable().references(BodySystems, #id)();
  IntColumn get difficulty => integer().withDefault(const Constant(1))();
  TextColumn get domain => text().withDefault(const Constant('macro'))();
  TextColumn get imagePath => text().nullable()();
  TextColumn get imageCredit => text().nullable()();
}
