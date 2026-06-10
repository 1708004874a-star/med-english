import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/providers.dart';
import '../../../../domain/entities/clinical_case.dart';

/// All fictional clinical cases (from the bundled asset).
final allCasesProvider = FutureProvider<List<ClinicalCase>>((ref) async {
  final repo = ref.watch(clinicalCaseRepositoryProvider);
  return repo.getAllCases();
});

/// A single case by id.
final caseByIdProvider =
    FutureProvider.family<ClinicalCase?, int>((ref, id) async {
  final repo = ref.watch(clinicalCaseRepositoryProvider);
  return repo.getCaseById(id);
});

const _solvedKey = 'solved_case_ids';

/// Set of case ids the user has completed, persisted in SharedPreferences.
final solvedCasesProvider =
    StateNotifierProvider<SolvedCasesNotifier, Set<int>>(
  (ref) => SolvedCasesNotifier()..load(),
);

class SolvedCasesNotifier extends StateNotifier<Set<int>> {
  SolvedCasesNotifier() : super(const {});

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_solvedKey) ?? const [];
    state = ids.map(int.parse).toSet();
  }

  Future<void> markSolved(int caseId) async {
    if (state.contains(caseId)) return;
    final next = {...state, caseId};
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _solvedKey, next.map((e) => e.toString()).toList());
  }
}
