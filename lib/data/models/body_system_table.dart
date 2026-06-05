import 'package:drift/drift.dart';

class BodySystems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nameEn => text()();
  TextColumn get nameZh => text()();
  TextColumn get iconName => text()();
  TextColumn get colorHex => text()();
  TextColumn get domain => text().withDefault(const Constant('macro'))();
}
