import 'package:drift/drift.dart';
import 'body_system_table.dart';

class KnowledgeArticles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get systemId => integer().references(BodySystems, #id)();
  TextColumn get titleEn => text()();
  TextColumn get titleZh => text()();
  TextColumn get contentEn => text()();
  TextColumn get contentZh => text()();
  IntColumn get difficulty => integer().withDefault(const Constant(1))();
  TextColumn get domain => text().withDefault(const Constant('macro'))();
}
