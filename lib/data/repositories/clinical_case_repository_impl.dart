import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/clinical_case.dart';
import '../../domain/repositories/i_clinical_case_repository.dart';

/// Loads fictional clinical cases from the bundled JSON asset and caches them
/// for the session.
class ClinicalCaseRepositoryImpl implements IClinicalCaseRepository {
  ClinicalCaseRepositoryImpl({AssetBundle? bundle}) : _bundle = bundle;

  static const _assetPath = 'assets/data/clinical_cases.json';

  final AssetBundle? _bundle;
  List<ClinicalCase>? _cache;

  Future<List<ClinicalCase>> _load() async {
    if (_cache != null) return _cache!;
    final bundle = _bundle ?? rootBundle;
    final raw = await bundle.loadString(_assetPath);
    final List<dynamic> data = json.decode(raw) as List<dynamic>;
    _cache = data
        .map((e) => ClinicalCase.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  @override
  Future<List<ClinicalCase>> getAllCases() => _load();

  @override
  Future<ClinicalCase?> getCaseById(int id) async {
    final cases = await _load();
    for (final c in cases) {
      if (c.id == id) return c;
    }
    return null;
  }
}
