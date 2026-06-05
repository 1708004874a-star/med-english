import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/body_system.dart';
import '../../../../domain/entities/morpheme.dart';
import '../../../../domain/entities/vocabulary.dart';
import '../../../../data/providers.dart';

// ── Body Systems ──────────────────────────────────────────────────────────────

final allSystemsProvider = FutureProvider<List<BodySystem>>((ref) {
  return ref.watch(vocabularyRepositoryProvider).getAllSystems();
});

// ── Vocabulary List ───────────────────────────────────────────────────────────

final selectedSystemProvider = StateProvider<int?>((ref) => null);

final vocabSearchQueryProvider = StateProvider<String>((ref) => '');

final vocabDisplayProvider = FutureProvider<List<Vocabulary>>((ref) async {
  final query = ref.watch(vocabSearchQueryProvider);
  final repo = ref.watch(vocabularyRepositoryProvider);

  if (query.isNotEmpty) {
    return repo.searchVocab(query);
  }

  final systemId = ref.watch(selectedSystemProvider);
  return systemId == null ? repo.getAllVocab() : repo.getVocabBySystem(systemId);
});

// ── Vocabulary Detail ─────────────────────────────────────────────────────────

final vocabDetailProvider =
    FutureProvider.family<Vocabulary?, int>((ref, vocabId) {
  return ref.watch(vocabularyRepositoryProvider).getVocabById(vocabId);
});

final isInNotebookProvider = FutureProvider.family<bool, int>((ref, vocabId) {
  return ref.watch(notebookRepositoryProvider).isInNotebook(vocabId);
});

// ── Morphemes ─────────────────────────────────────────────────────────────────

final morphemeTypeFilterProvider = StateProvider<String?>((ref) => null);

final filteredMorphemesProvider = FutureProvider<List<Morpheme>>((ref) async {
  final repo = ref.watch(morphemeRepositoryProvider);
  final type = ref.watch(morphemeTypeFilterProvider);
  return type == null ? repo.getAllMorphemes() : repo.getMorphemesByType(type);
});

final morphemeDetailProvider =
    FutureProvider.family<Morpheme?, int>((ref, morphemeId) {
  return ref.watch(morphemeRepositoryProvider).getMorphemeById(morphemeId);
});

final vocabForMorphemeProvider =
    FutureProvider.family<List<Vocabulary>, int>((ref, morphemeId) {
  return ref.watch(morphemeRepositoryProvider).getVocabForMorpheme(morphemeId);
});
