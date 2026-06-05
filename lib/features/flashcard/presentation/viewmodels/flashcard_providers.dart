import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../data/providers.dart';
import '../../../../domain/entities/vocabulary.dart';

final flashcardBatchProvider =
    FutureProvider.family<List<Vocabulary>, int?>((ref, systemId) {
  return ref.watch(vocabularyRepositoryProvider).getFlashcardBatch(
        systemId: systemId,
        count: kDefaultFlashcardSessionSize,
      );
});
