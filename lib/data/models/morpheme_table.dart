import 'package:drift/drift.dart';

class WordMorphemes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get morpheme => text()();
  TextColumn get type => text()(); // 'prefix' | 'suffix' | 'root'
  TextColumn get meaningZh => text()();
  TextColumn get meaningEn => text()();
  TextColumn get origin => text().nullable()();
  TextColumn get domain => text().withDefault(const Constant('macro'))();
}
