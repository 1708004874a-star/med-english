import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers.dart';
import '../../../../domain/entities/notebook_entry.dart';

enum NotebookFilter { all, needsReview, mastered }

final notebookFilterProvider =
    StateProvider<NotebookFilter>((_) => NotebookFilter.all);

final notebookStreamProvider = StreamProvider<List<NotebookEntry>>((ref) {
  return ref.watch(notebookRepositoryProvider).watchAll();
});
