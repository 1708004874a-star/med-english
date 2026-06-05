import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../data/providers.dart';
import '../../../../data/settings_providers.dart';
import '../../../../domain/entities/vocabulary.dart';

final flashcardBatchProvider =
    FutureProvider.family<List<Vocabulary>, int?>((ref, systemId) {
  final domain = ref.watch(domainProvider);
  return ref.watch(vocabularyRepositoryProvider).getFlashcardBatch(
        systemId: systemId,
        domain: domain.name,
        count: kDefaultFlashcardSessionSize,
      );
});
