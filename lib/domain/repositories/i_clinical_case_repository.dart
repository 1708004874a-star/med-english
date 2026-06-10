import '../entities/clinical_case.dart';

/// Source of fictional clinical cases.
///
/// The default implementation loads pre-authored cases from a bundled JSON
/// asset (offline). A future implementation could generate cases via an LLM
/// API without touching the UI — callers depend only on this interface.
abstract interface class IClinicalCaseRepository {
  Future<List<ClinicalCase>> getAllCases();
  Future<ClinicalCase?> getCaseById(int id);
}
