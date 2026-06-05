class BodySystem {
  const BodySystem({
    required this.id,
    required this.nameEn,
    required this.nameZh,
    required this.iconName,
    required this.colorHex,
  });

  final int id;
  final String nameEn;
  final String nameZh;
  final String iconName;
  final String colorHex;

  @override
  bool operator ==(Object other) =>
      other is BodySystem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
