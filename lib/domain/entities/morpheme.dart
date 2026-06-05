import '../../core/constants/db_constants.dart';

class Morpheme {
  const Morpheme({
    required this.id,
    required this.morpheme,
    required this.type,
    required this.meaningZh,
    required this.meaningEn,
    this.origin,
  });

  final int id;
  final String morpheme;
  final MorphemeType type;
  final String meaningZh;
  final String meaningEn;
  final String? origin;

  @override
  bool operator ==(Object other) =>
      other is Morpheme && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
